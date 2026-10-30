# Wowhead Quick Link
Mouse over and press CTRL-C on (almost) anything to generate a Wowhead or Armory link. Allows you to quickly look up anything on Wowhead without having to manually search for it. Lightweight and efficient.

Supports generating links to the Wowhead page for quests, achievements, items, spells, buffs, NPCs, mounts, battle pets, factions, or currencies by pressing CTRL-C while mousing over, as well as armory links for player characters. Also supports Raider.IO links by pressing CTRL-SHIFT-C.


## Exact item versions (this fork)

Item links keep their **bonus IDs**, so the generated link points to the exact version of the item
(Normal, Heroic, Mythic, Warforged...), for example `https://www.wowhead.com/item=124182?bonus=9081`
for the Mythic version. This works for item links in chat, items in bags, the Auction House and
tooltips, and for pieces in the Appearances and Sets tabs of the Collections window, where the
appearance source gives the link of that exact version. Classic flavors are unchanged.

Upstream AddOn: https://www.curseforge.com/wow/addons/wowhead-quick-link
