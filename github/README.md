# Read Me

```powershell
$orgName  = 'myOrg'
$repoName = 'myRepo'
$url      = "https://github.com/$orgName/$repoName.git"
```

```powershell
# Create new repo
Write-Output "# $repoName" >> README.md
git init
git add README.md
git commit -m 'first commit'
git branch -M main
git remote add origin $url
git push -u origin main
```

```powershell
# Push existing repo
git remote add origin $url
git branch -M main
git push -u origin main
```
