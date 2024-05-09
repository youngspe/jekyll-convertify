`jekyll-convertify` is a plugin for [Jekyll](https://jekyllrb.com/)
to combine multiple document types in a page or file.
It does so by looking up the appropriate [converters](https://jekyllrb.com/docs/plugins/converters/),
if available, and converting the provided source to the desired type.

For example, this could be used to embed Markdown in an HTML file.

https://rubygems.org/gems/jekyll-convertify

## Features

### `convertify` block tag

#### Syntax

```
{% convertify from .<SRC> [to .<DST>] %}
...
{% endconvertify %}
```

#### Explicit destination type

When this form is used, content will be converted from the source type (`SRC`)
to the destination type (`DST`). In this usage sample, the types are `.md` and `.html` respectively:

```
{% convertify from .md to .html %}
...
{% endconvertify %}
```

#### Implicit destination type

When this form is used, the destination type will be inferred from context.
If no converter is available for the inferred destination type, Convertify will
use the first converter it finds that transforms the source type (`SRC`) to another type.
In this usage sample, the source type is `.md` and the destination type is inferred from context:

```
{% convertify from .md %}
...
{% endconvertify %}
```

#### Example

**Source: (pages/my_page1.html)**

```
<style>
{% convertify from .sass to .css %}
p
  font-family: sans-serif
  color: #803010
{% endconvertify %}
</style>
```

**Rendered: ([pages/my_page1](https://youngspe.github.io/jekyll-convertify/pages/my_page1))**

```
<style>
p {
  font-family: sans-serif;
  color: #803010;
}
</style>
```

### `convertify` filter

#### Syntax

```
{% <CONTENT> | convertify: ".<SRC>" [, .<DST>] }
```

#### Explicit destination type

```
{% "**foo**" | convertify: ".md", ".html" }
```

#### Implicit destination type

```
{% "**foo**" | convertify: ".md" }
```

#### Example

**Source: (pages/my_page2.html)**

```
<section>
{{ "
h2> MinTyML section

This is the <_MinTyML_> section.
" | convertify: ".mty" }}
</section>
```

**Rendered: ([pages/my_page2](https://youngspe.github.io/jekyll-convertify/pages/my_page2))**

```
<section>

<h2>MinTyML section</h2>

<p>This is the <u>MinTyML</u> section.</p>

</section>
```

### `convertify_include` tag

#### Syntax

```
{% convertify_include <PATH> [<PARAM>=<VALUE>]* [as .<DST>] %}
```

#### Explicit destination type

```
{% convertify_include header.md as .html %}
```

#### Implicit destination type

```
{% convertify_include header.md %}
```

#### Example

**Source: (pages/my_page3.html)**

```
<style>
{% convertify_include sass_include.sass color="#000080" as .css %}
</style>
```

**Source: (_includes/sass_include.sass)**

```
h1,h2,h3,h4,h5,h6
  color: {{ include.color }}
```

**Rendered: ([pages/my_page3](https://youngspe.github.io/jekyll-convertify/pages/my_page3))**

```
<style>
h1,h2,h3,h4,h5,h6 {
  color: #000080;
}
</style>
```

### `convertify_include_relative` tag

#### Syntax

```
{% convertify_include_relative <PATH> [<PARAM>=<VALUE>]* [as .<DST>] %}
```

#### Explicit destination type

```
{% convertify_include_relative chunk.mty as .html %}
```

#### Implicit destination type

```
{% convertify_include_relative chunk.mty %}
```

#### Example

**Source: (pages/my_page4.html)**

```
<section>
{% convertify_include_relative _asciidoc_chunk.adoc %}
</section>
```

**Source: (pages/_asciidoc_chunk.adoc)**

```
== AsciiDoc section

This is the *AsciiDoc section*
```

**Rendered: ([pages/my_page4](https://youngspe.github.io/jekyll-convertify/pages/my_page4))**

```
<section>
<div class="sect1">
  <h2 id="asciidoc-section">AsciiDoc section</h2>
  <div class="sectionbody">
    <div class="paragraph">
      <p>This is the <strong>AsciiDoc section</strong></p>
    </div>
  </div>
</div>
</section>
```
