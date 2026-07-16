window.LEAGUE_CONFIG = {
  name: "Mamelodi Local Football Association",
  shortName: "MALFA",
  strapline: "One association. Every division.",
  season: "2026",
  region: "Mamelodi, Pretoria",
  email: "info@malfa.co.za",
  logo: "assets/malfa-logo.png"
};

window.MALFA_DEFAULT_DATA = {
  competitions: [
    { id: "u11", slug: "u11", name: "Under 11", short_name: "U11", category: "Junior", type: "league", description: "Foundation football and early player development.", accent: "#e23b47", sort_order: 10, active: true, visible: true },
    { id: "u13", slug: "u13", name: "Under 13", short_name: "U13", category: "Junior", type: "league", description: "Technical growth and competitive junior football.", accent: "#e23b47", sort_order: 20, active: true, visible: true },
    { id: "u15", slug: "u15", name: "Under 15", short_name: "U15", category: "Junior", type: "league", description: "A key development stage for young players and teams.", accent: "#d8202f", sort_order: 30, active: true, visible: true },
    { id: "u17", slug: "u17", name: "Under 17", short_name: "U17", category: "Junior", type: "league", description: "Advanced youth competition preparing players for senior football.", accent: "#c21827", sort_order: 40, active: true, visible: true },
    { id: "u19", slug: "u19", name: "Under 19", short_name: "U19", category: "Junior", type: "league", description: "The bridge between junior development and senior football.", accent: "#ab101d", sort_order: 50, active: true, visible: true },
    { id: "mpl", slug: "mpl", name: "Men's Promotional League", short_name: "MPL", category: "Senior", type: "league", description: "Senior competition and a pathway towards promotion.", accent: "#8f0d18", sort_order: 60, active: true, visible: true },
    { id: "super-league", slug: "super-league", name: "Super League", short_name: "SUPER", category: "Senior", type: "league", description: "The leading MALFA senior league competition.", accent: "#202020", sort_order: 70, active: true, visible: true },
    { id: "wpl", slug: "wpl", name: "Women's Promotional League", short_name: "WPL", category: "Women", type: "league", description: "Competitive women's football and a platform for growth.", accent: "#ef5964", sort_order: 80, active: true, visible: true }
  ],
  clubs: [],
  entries: [],
  fixtures: [],
  standings: [],
  news: [
    {
      id: "malfa-platform",
      slug: "malfa-digital-competition-centre",
      title: "A new digital home for every MALFA division",
      category: "Association Update",
      excerpt: "Fixtures, verified results, tables, clubs and news are now organised in one competition platform.",
      body: "The MALFA competition platform has been structured to serve junior football, senior leagues, women's football and future cup competitions.\n\nAuthorised administrators can publish verified results, manage fixtures, update clubs and crests, calculate league tables and reveal tournament sections when cup competitions are ready.",
      image_url: null,
      competition_id: null,
      club_id: null,
      published: true,
      published_at: "2026-07-16T09:00:00+02:00"
    }
  ],
  partners: [],
  settings: { season: "2026", show_tournaments: true, show_partners: true }
};
