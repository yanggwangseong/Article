---
layout: posts
title: 게시물 목록
permalink: /posts/
---

<ul class="post-list">
  {% for note in notes %}
  <li class="post-card">
    <a href="{{ note.url }}" class="post-link">
      <div class="post-thumb">
        <img src="{{ note.image | default: '/assets/default_thumbnai.jpg' }}" alt="썸네일" />
      </div>
      <div class="post-info">
        <div class="post-title">{{ note.title }}</div>
        <div class="post-meta">
          {% if note.last_modified_at %}
            {{ note.last_modified_at | date: "%Y-%m-%d" }}
          {% endif %}
        </div>
        <div class="post-excerpt">
          {{ note.excerpt | default: note.content | strip_html | truncatewords: 30 }}
        </div>
      </div>
    </a>
  </li>
  {% endfor %}
</ul>
