param (
    [string]$VERSION = ""
)

# get highest tag number, and add v0.1.0 if doesn't exist
git fetch --prune --unshallow 2>$null
$CURRENT_VERSION = git describe --abbrev=0 --tags 2>$null

if (-not $CURRENT_VERSION) {
    $CURRENT_VERSION = 'v0.1.0'
}
Write-Host "Current Version: $CURRENT_VERSION"

# split version into parts
$CURRENT_VERSION_PARTS = $CURRENT_VERSION -split '\.'
$VNUM1 = $CURRENT_VERSION_PARTS[0]
$VNUM2 = $CURRENT_VERSION_PARTS[1]
$VNUM3 = $CURRENT_VERSION_PARTS[2]

if ($VERSION -eq 'major') {
    $VNUM1 = "v$($VNUM1+1)"
}
elseif ($VERSION -eq 'minor') {
    $VNUM2++
}
elseif ($VERSION -eq 'patch') {
    $VNUM3++
}
else {
    Write-Host "No version type (https://semver.org/) or incorrect type specified, try: -v [major, minor, patch]"
    exit 1
}

# create new tag
$NEW_TAG = "$VNUM1.$VNUM2.$VNUM3"
Write-Host "($VERSION) updating $CURRENT_VERSION to $NEW_TAG"

# get current hash and see if it already has a tag
$GIT_COMMIT = git rev-parse HEAD
$NEEDS_TAG = git describe --contains $GIT_COMMIT 2>$null

# only tag if no tag already
if (-not $NEEDS_TAG) {
    Write-Host "Tagged with $NEW_TAG"
    git tag $NEW_TAG
    git push --tags
    git push
}
else {
    Write-Host "Already a tag on this commit"
}

Write-Output "::set-output name=new-version::$NEW_TAG"
