# QBCore BackItems System

A simple system for QBCore that shows weapons and items on the player's back based on their clothing. Great for adding realism to your server!

---

## Features
- Show weapons and items on the back.
- Restrict visibility based on clothing (bags, undershirts, etc.).
- Easy to customize models and settings.

---

## Installation

1. Download the resource and place it in your `resources` folder.
2. Add it to your `server.cfg`: ensure qb-backitems 
3. Edit `config.lua` to match your server's setup.

---

## Configuration

Here’s a quick example:

```lua
Config = {
 restrictedBags = {
     [40] = true, -- Add bag IDs to block
     [41] = true,
 },

 BackItems = {
     ["MARKEDBILLS"] = {
         model = "prop_money_bag_01",
         quantity = 1,
         back_bone = 24818,
         x = -0.6,
         y = -0.17,
         z = -0.12,
         x_rotation = 0.0,
         y_rotation = 90.0,
         z_rotation = 0.0,
     },
 },
}
```
#### Preview
(https://youtu.be/i3b4V1Q4hRc)
