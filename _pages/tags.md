---
layout: default
title: 전체 태그 목록
permalink: /tags/
---

<div class="tags-page">
  <h1>전체 태그 목록</h1>
  
  {% assign tags = site.notes | map: 'tags' | flatten | uniq | sort %}
  
  <div class="tags-list">
    {% for tag in tags %}
      <a href="/tags/{{ tag }}" class="tag">
        {{ tag }} ({{ site.notes | where_exp: "item", "item.tags contains tag" | size }})
      </a>
    {% endfor %}
  </div>
</div>

<style>
.tags-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.tags-list {
  margin: 2rem 0;
}
</style>
