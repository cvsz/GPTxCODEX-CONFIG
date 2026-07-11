#!/usr/bin/env python3
"""Fail when GitHub does not mark in-scope commits as cryptographically verified."""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

POLICY_PATH = ".github/workflows/verify-signatures.yml"


def make_request(url: str, token: str) -> urllib.request.Request:
    return urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "gptxcodex-signature-check",
        },
    )


def api_get(url: str, token: str) -> tuple[Any, dict[str, str]]:
    request = make_request(url, token)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            body = json.load(response)
            headers = {key.lower(): value for key, value in response.headers.items()}
            return body, headers
    except urllib.error.HTTPError as exc:
        details = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"GitHub API request failed ({exc.code}): {details}") from exc


def api_exists(url: str, token: str) -> bool:
    request = make_request(url, token)
    try:
        with urllib.request.urlopen(request, timeout=30):
            return True
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            return False
        details = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"GitHub API request failed ({exc.code}): {details}") from exc


def next_link(link_header: str | None) -> str | None:
    if not link_header:
        return None
    for entry in link_header.split(","):
        parts = [part.strip() for part in entry.split(";")]
        if len(parts) >= 2 and parts[1] == 'rel="next"':
            return parts[0].strip("<>")
    return None


def collect_pr_commits(api_url: str, repository: str, pr_number: int, token: str) -> list[dict[str, Any]]:
    url = f"{api_url}/repos/{repository}/pulls/{pr_number}/commits?per_page=100"
    commits: list[dict[str, Any]] = []
    while url:
        page, headers = api_get(url, token)
        if not isinstance(page, list):
            raise RuntimeError("Unexpected GitHub API response while listing pull request commits")
        commits.extend(page)
        url = next_link(headers.get("link"))
    return commits


def collect_push_commits(api_url: str, repository: str, event: dict[str, Any], token: str) -> list[dict[str, Any]]:
    shas = [item.get("id") for item in event.get("commits", []) if item.get("id")]
    head = event.get("after")
    if head and head.strip("0") and head not in shas:
        shas.append(head)

    commits: list[dict[str, Any]] = []
    for sha in shas:
        commit, _ = api_get(f"{api_url}/repos/{repository}/commits/{urllib.parse.quote(sha)}", token)
        commits.append(commit)
    return commits


def base_contains_policy(api_url: str, repository: str, event: dict[str, Any], token: str) -> bool:
    base_sha = ((event.get("pull_request") or {}).get("base") or {}).get("sha")
    if not base_sha:
        raise RuntimeError("Pull request base SHA is missing from the event payload")
    encoded_path = urllib.parse.quote(POLICY_PATH, safe="/")
    encoded_ref = urllib.parse.quote(base_sha)
    url = f"{api_url}/repos/{repository}/contents/{encoded_path}?ref={encoded_ref}"
    return api_exists(url, token)


def main() -> int:
    token = os.environ.get("GITHUB_TOKEN")
    repository = os.environ.get("GITHUB_REPOSITORY")
    api_url = os.environ.get("GITHUB_API_URL", "https://api.github.com")
    event_name = os.environ.get("GITHUB_EVENT_NAME")
    event_path = os.environ.get("GITHUB_EVENT_PATH")

    missing = [
        name
        for name, value in {
            "GITHUB_TOKEN": token,
            "GITHUB_REPOSITORY": repository,
            "GITHUB_EVENT_NAME": event_name,
            "GITHUB_EVENT_PATH": event_path,
        }.items()
        if not value
    ]
    if missing:
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

    event = json.loads(Path(event_path).read_text(encoding="utf-8"))

    if event_name == "pull_request":
        if not base_contains_policy(api_url, repository, event, token):
            print(
                f"Bootstrap mode: {POLICY_PATH} is not present on the pull request base. "
                "Skipping verification for the policy-introduction pull request only."
            )
            return 0
        commits = collect_pr_commits(api_url, repository, int(event["number"]), token)
    elif event_name == "push":
        commits = collect_push_commits(api_url, repository, event, token)
    elif event_name == "workflow_dispatch":
        sha = os.environ.get("GITHUB_SHA")
        if not sha:
            raise RuntimeError("GITHUB_SHA is required for workflow_dispatch")
        commit, _ = api_get(f"{api_url}/repos/{repository}/commits/{sha}", token)
        commits = [commit]
    else:
        print(f"Event {event_name!r} is not subject to signature verification.")
        return 0

    failures: list[str] = []
    for item in commits:
        sha = item.get("sha", "<unknown>")
        commit = item.get("commit", {})
        verification = commit.get("verification") or {}
        verified = verification.get("verified") is True
        reason = verification.get("reason", "unknown")
        author = (commit.get("author") or {}).get("name", "unknown")
        subject = (commit.get("message") or "").splitlines()[0]

        marker = "VERIFIED" if verified else "UNVERIFIED"
        print(f"{marker} {sha[:12]} {author}: {subject} (reason={reason})")
        if not verified:
            failures.append(f"{sha}: reason={reason}")

    if failures:
        print("\nThe following commits are not marked Verified by GitHub:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        print("\nSee GPG_SIGNING.md for setup and remediation instructions.", file=sys.stderr)
        return 1

    print(f"All {len(commits)} in-scope commit(s) are cryptographically verified by GitHub.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # CI entry point: report actionable diagnostics.
        print(f"Signature verification failed: {exc}", file=sys.stderr)
        raise SystemExit(2) from exc
