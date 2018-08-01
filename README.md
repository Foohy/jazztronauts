[![ko-fi](https://www.ko-fi.com/img/donate_sm.png)](https://ko-fi.com/N4N6H7ZH)

# Jazztronauts
Videogames are the poison, Jazztronauts is the cure.


### What is this
Jazztronauts is a cooperative theft-em-up for Garry's Mod, also known as prop hunt 2.
Go to random maps on the workshop, pillage its trash for money, and converse with your higher-dimensional cat overlords.

- If you want instructions on installing it the normal way, follow this link for the official FAQ.
- Else, this repo can just be smashed into your addons folder, it is a self-contained jazztronauts installation

### Features
- Dynamically download and mount workshop map addons
- Load in BSP data for specific effects, such as stealing static props and world brushes
- Dynamic dialog/mission system
- Persistent player data, and newgame+ mode
- Hammer I/O viewer gun, watch I/O events happen in real time
- Lots of pretty pretty art

### Contributions
This repository is hooked up to build and upload directly to the workshop addon "whenever™". 
Contributions are always welcome, and can be done through the normal github pull request avenue, and I'll try to update the workshop version as soon as I can after that.

### INSTALLATION AND PLAY FAQ

- How do I download Jazztronauts?

There are two different ways to download Jazztronauts. First, you can go to the Steam Workshop and select either the [Jazztronauts - Vanilla collection](https://steamcommunity.com/workshop/filedetails/?id=1455883814) if you want the addon on its own, or the [Jazztronauts - Recommended collection](https://steamcommunity.com/workshop/filedetails/?id=145588732) if you’d like to bundle in some addons we think makes the mode even more entertaining. **If using the Steam Workshop version of Jazztronauts, it is critical to make sure you are subscribed to all three pieces of the mod! If you are not subscribed to the base pack and both content packs, the mod will not function properly! Always double check this first if you have a problem!**

The other way to get the files is to go to GitHub and click the green button near the top right to download the source code as a .zip file. 

- How do I install Jazztronauts?

If you’re subscribed to Jazztronauts via Steam Workshop, the mod will install itself the next time you open Gmod. If you got it off GitHub, unzip the repo into GarrysMod’s installation via steamapps/common/GarrysMod/garrysmod.

- How do I start a game of Jazztronauts?

Gmod’s user interface is a little unintuitive, to say the least, so don’t worry if you got stuck. The first step is to look at the bottom right of the screen, to the game mode selection widget. If you click it, it should look something like this:

![alt text](https://i.imgur.com/6KwEHM6.png)

Click the Jazztronauts mode. Then, go back up to Start New Game in the top left, and click it. You’ll see a big window with map types listed – Jazztronauts should be listed there with five maps. If it isn’t, make sure you’re subscribed to all three content packs on the Workshop, or have installed the game correctly. When you click it, it should look like this:

![alt_text](https://i.imgur.com/vOFSo3p.png)

Next, go over to the top right and click the button that says Single Player. 

![alt_text](https://i.imgur.com/eFPxwI6.png)

Do NOT keep it on single player even if you want to play a solo game! Change it to two players, disable peer to peer, and enable local server. Read below for why that’s necessary.

For everyone else, this is where you define the player cap of your session, and can enable friends only mode. We believe the best experience with the game is with 3 to 6 players, and that it will likely function Okay at up to 16 players, but any more than that and you’re putting your fate in your own hands.

Once that’s set up, select the jazz_bar map, click Start Game, and you're ready to go!

- I see a bunch of models that say ERROR and everything’s covered in horrible pink and black checkerboard, help!

Gmod expects players to have locally saved copies of the assets used in maps. If they don’t, it shows broken textures and ERROR models. While some maps may have these errors due to niche assets we can’t account for, or just plain shabby design, the majority of these errors come from not having assets from Valve games. For best results, the assets provided with Half-Life 2, HL2: Episodes 1 & 2, Counterstrike Source (not CSGO!), and Team Fortress 2 should be installed on your computer or server while playing Jazztronauts. The game is technically playable if you don’t have any of those, it’s just going to look REAL ugly when you go to other maps.

- How does Jazztronauts save progress?

Jazztronauts stores progression data on the computer of the person hosting a session, or the dedicated server being used. This means that if you play a session of Jazztronauts hosted by Friend A, and play another hosted by Friend B, you will not transfer any of your progress over, and instead be awarded money based on the progression of Friend B’s sessions. **If you play Jazztronauts consistently with the same people, the same person should always host the game, so you can maintain your progress.** Dedicated servers do not need any special treatment – anyone who’s played on the server before will maintain their progress when they return (unless the server has been reset), and new players will be caught up to the current progression level.

- I keep getting script errors, and things don’t seem to be working right. What gives?

Are you trying to play a single player game? Game modes in Gmod tend to throw a fit when you try doing it the intuitive way. As mentioned earlier, the “Single Player” option in the top right of the Start New Game menu does not actually work. The scripting in Jazztronauts only works when a player limit of 2 or more has been selected. If, however, you disable peer-to-peer and enable the Local Server option, you will stay offline and be able to play the game single player.

![alt_text](https://i.imgur.com/wkHQWNB.png)

If you’re playing single player, your options should look like this!

- How do I support the developers?

You can follow us on Twitter at @JazzSourceMod if you aren’t already. If any member of the team goes on to do similar projects, we’ll use the account to advertise them. You can also tell your friends about us, or stream the game! We’ve gotten the audience we have almost entirely through word-of-mouth and streams. Lastly, we’ve set up a Ko-fi at www.ko-fi.com/jazzsourcemod as a digital tip jar if you want to express your generosity that way. To be completely up front, any donations we get through it will not make further development more likely – we’d just be bewildered at your generosity and appreciate it a lot.
