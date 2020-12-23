[![lint](https://github.com/jmpa-oss/website-template/workflows/lint/badge.svg)](https://github.com/jmpa-oss/website-template/actions?query=workflow%3Alint)

# website-template

```diff
+ A base template used to create child website repositories.
```

## create

To learn about creating a repository template in GitHub, see [this doc](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

## update

For a new repository, you must first run:
```bash
git remote add template "https://github.com/jmpa-oss/website-template.git"
git fetch template
git merge template/master

# see ./bin/update-template.sh for a working example.
```

Then, to update thereafter, run:
```bash
./bin/update-template.sh
```
