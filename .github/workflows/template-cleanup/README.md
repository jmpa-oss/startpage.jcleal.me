[![cicd](https://github.com/jmpa-oss/%WEBSITE%/workflows/cicd/badge.svg)](https://github.com/jmpa-oss/%WEBSITE%/actions?query=workflow%3Acicd)
[![update](https://github.com/jmpa-oss/%WEBSITE%/workflows/update/badge.svg)](https://github.com/jmpa-oss/%WEBSITE%/actions?query=workflow%3Aupdate)

# %WEBSITE%

```diff
+ %DESCRIPTION%
```

## lint?

Using a <kbd>terminal</kbd>, run:
```bash
./bin/10-lint.sh
```

## deploy?

Using a <kbd>terminal</kbd>, run:
```bash
./bin/20-deploy.sh <path-to-template|template-name>

# for example
./bin/20-deploy.sh cf/template.yml
```

## upload website to s3?

To upload the static compiled website to s3, using a <kbd>terminal</kbd>, run:
```bash
./bin/30-sync.sh
```