// ---- Scrapyard: a fresh base design (owner, 2026-10-19: "completely redesign the scrapyard from scratch", direction: Smelting Works) ----------------
// The old Magnet Yard base look and every old upgrade design are dropped. The look itself is drawn by the second-pass model (data_p2_scrap.js), which
// draws the whole yard at every level, so this base file only names the look and the animation for the page header.
const PAGE = { title: "Scrapyard base (smelting works)", store: "bl-tower-art-scrap-base-sw" };
const TOWERS = [
  { id: "scrap", num: 17, name: "Scrapyard", cls: "Utility", weapon: "None", hits: "none", size: 2, center: [0.3, 0.4], color: [1.0, 0.62, 0.22, 1],
    desc: "Various collections of scrap metal sold at a profit. \"One mans toxic waste is another mans potpourri\" A 2x2 smelting works; it attacks nothing and pays 100 credits at each round's clear (the preview pays every 4 s).",
    looks: [
      { key: "A", name: "Smelting Works", muzzle: 0, fixed: true, theme: "A foundry yard: a brick furnace with a glowing mouth fed by a scrap conveyor, a chimney, and a molten channel running to a row of ingot moulds.", draw() {} },
    ],
    anims: [
      { key: "A", name: "Pour and Payout", desc: "At each round's clear the furnace flares, molten metal runs down the channel into the moulds, the ingots flash gold and a spray of credit coins pops out with the payout.", period: 1, flight: 1, fx: () => ({}), persist: () => {} },
    ] },
];
