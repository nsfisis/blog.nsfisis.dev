# My note

## Commands

Generate the site.

```
$ make gen
```

Create a new post.

```
$ mkdir -p content/posts/$(date +'%Y-%m-%d')
$ touch content/posts/$(date +'%Y-%m-%d')/[TITLE].md
```

## TODO

* [x] Add /posts/ page
* [x] Stylesheets
* [x] Syntax highlight
* [ ] Add / page
* [ ] Add /about/ page
* [ ] Add navigation bar
    * Site name
    * Posts
    * Tags
    * About
* [ ] Paging
    * /posts/
        * /posts/?p=1 => /posts/
* [ ] RSS feed
    * /posts/feed.xml
    * /tags/<tag>/feed.xml
* [ ] Redirect
    * [x] Old URLs
    * [ ] /posts/?p=1
        => /posts/
            => /posts/_page/1.html
    * [ ] /posts/?p=2
        => /posts/_page/2.html
    * [ ] /
        => /posts/
* [ ] Sitemap
    * https://www.sitemaps.org/protocol.html
    * https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap?hl=ja


## Structure

```
public
├── sitemap.xml
├── 404.html
├── posts
│   ├── 2021-03-05
│   │   └── my-first-post
│   │       └── index.html
│   ├── feed.xml
│   ├── _page
│   │   ├── 1.html
│   │   └── 2.html
└── tags
    ├── index.html
    └── vim
        ├── feed.xml
        └── index.html
```


## References

* https://docs.asciidoctor.org/asciidoctor/latest/
