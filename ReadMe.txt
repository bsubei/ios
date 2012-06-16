this is for reference (ask Bash for a quick tut)...


Remember, after saving your work in Xcode, head on to SourceTree and perform these steps.
These commands are easy to perform using SourceTree (using a GUI instead of commandLine).

Always follow these steps:

1- always commit FIRST (unless u want to discard all your local changes).
2- then PULL to check if server has any changes. IF PULL GIVES NO CHANGES, SKIP TO STEP 6.
3- if there is a conflict (u changed a file that someone else changed), merge (use sourceTree to do this nicely). Contact Bash if you are unsure (i will have to figure it out).
4- go back to step 1 (in case while you followed these steps, someone else pushed).
5- update your local repo files.
6- push your committed changes unto the server repo files.



common commands (short description):

- commit: saves all changes in ur local repo files.
- pull: retrieves changes between the server repo files and your local repo files.
- update: (used after pull) updates your local repo files to match pulled changes.
- push: uploads your saved changes (your committed local repo files) to the server repo.
- merge: (when 2 users changed one file independently) merges both changes into conflicted file.


edit ur files… then save