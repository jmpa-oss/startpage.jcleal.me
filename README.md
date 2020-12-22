# repo-template

```diff
+ A template used as a base for other repositories in this org.
```

## create

To learn about creating a repository template in GitHub, see [this doc](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template).

## update

For a new repository, you must first run:
```bash
git remote add template "https://github.com/jmpa-oss/repo-template.git"
```

Then, to update thereafter, run:
```bash
./bin/update.sh
```
