# sta302-project
Repo for the STA302H1F24 course.

## WARNING
There are still some things we need to do in Main.R:
- [ ]: Do work for left-handed pitchers (or decide not to do them)
- [ ]: Add transformations (if needed)
- [ ]: Add descriptions (where it says "Description" use Ctrl+F)
- [ ]: Fix the boxplot, qq plot, pairs problem (tbh fixable with filtering ones with small count, but do we need to find another way?)
Make sure to also check the rubric in case we missed something.


## How to Run
1. Run DownloadSavantData.R (if needed)
2. Run HowToSavantData.R (can be run on Main.R)
3. Run Main.R

## Working together
Work on your own files to prevent git conflict craziness. Try to not make changes to others' file.

If you remember how to branch and merge, feel free to do so.

Commands:
Initial branching setup (if you decide to do so)
```bash
git checkout -b <branch_name>
git push -u origin <branch_name>
```

When pushing, remember to pull if working on main
```bash
git pull
# if there are conflicts resolve them, don't force push
git push
```