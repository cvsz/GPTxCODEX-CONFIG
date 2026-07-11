# Commit Signing Policy

All human-authored commits should be cryptographically signed and show **Verified** on GitHub before merge. GPG is the recommended method for this repository; GitHub-verified SSH or S/MIME signatures are also accepted by the automated check because GitHub exposes a unified verification result.

## Generate a GPG key on Windows

Install GnuPG through a trusted package source, then run:

```powershell
gpg --full-generate-key
```

Recommended choices:

- RSA and RSA or a modern ECC option supported by your Git and GitHub setup
- key size of 3072 or 4096 bits when using RSA
- an expiration date appropriate for your key-rotation policy
- the same verified email address used by your GitHub account

List the secret keys and copy the long key ID:

```powershell
gpg --list-secret-keys --keyid-format=long
```

Export the public key:

```powershell
gpg --armor --export <KEY_ID>
```

Add the exported public key in GitHub under **Settings → SSH and GPG keys → New GPG key**.

## Configure Git

Configure the repository or user profile:

```powershell
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true
git config --global tag.gpgSign true
git config --global gpg.program gpg
```

Confirm the email used by Git:

```powershell
git config --global user.email
```

The email must match an identity attached to the GPG key and a verified email on GitHub.

## Sign commits and tags

```powershell
git commit -S -m "feat: signed change"
git tag -s v1.0.0 -m "Release v1.0.0"
```

Verify locally:

```powershell
git log --show-signature -1
git verify-tag v1.0.0
```

## Existing unsigned commits

Re-sign only commits you authored and only on branches where history rewriting is safe:

```powershell
git rebase --rebase-merges --exec "git commit --amend --no-edit -S" <BASE_BRANCH>
```

Then push with lease protection:

```powershell
git push --force-with-lease
```

Never rewrite shared or protected branch history without explicit maintainer approval.

## Enforcement

The `Verify commit signatures` workflow fails when a pull request contains a commit that GitHub does not mark as verified. For full server-side enforcement, maintainers must also enable a GitHub ruleset or branch protection rule with **Require signed commits** for `main`.

Bot-authored commits may use GitHub's verified signatures. Exceptions require maintainer review and must be documented in the pull request.