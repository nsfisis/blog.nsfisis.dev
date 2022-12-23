export const config = {
  locations: {
    contentDir: "/content",
    destDir: "/public",
    staticDir: "/static",
    templateDir: "/templates",
  },
  rendering: {
    html: {
      indentWidth: 2,
    },
  },
  blog: {
    author: "nsfisis",
    siteName: "REPL: Rest-Eat-Program Loop",
    siteCopyrightYear: 2021,
    tagLabels: {
      "conference": "カンファレンス",
      "cpp": "C++",
      "cpp17": "C++ 17",
      "note-to-self": "備忘録",
      "php": "PHP",
      "phpcon": "PHP カンファレンス",
      "phperkaigi": "PHPerKaigi",
      "python": "Python",
      "python3": "Python 3",
      "ruby": "Ruby",
      "ruby3": "Ruby 3",
      "rust": "Rust",
      "vim": "Vim",
    },
  },
};

export type Config = typeof config;
