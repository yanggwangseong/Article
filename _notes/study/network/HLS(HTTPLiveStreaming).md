---
title: HLS(HTTPLiveStreaming)
permalink: /network/HLS(HTTPLiveStreaming)
tags: 
layout: note
image: 
category: 
description: HLS(HTTPLiveStreaming)
---

## 생각

WebRTC와 Socket을 통해서 실시간 채팅 구현까지는 바로 떠오르는데 이게 대규모 트래픽 시스템이라고 생각 했을때의 설계 생각을 해봐야 할것 같다.

예를 들면 숲이나 지지직 같은급의 HLS 플랫폼들



---

## HLS(HTTPLiveStreaming)

- HLS(HTTPLiveStreaming)

```
[WebRTC / RTMP 입력]
     ↓
[Transcoder (ffmpeg 등)]
     ↓
[Segmenter (ts 분할 및 m3u8 생성)]
     ↓
[Storage (로컬 or CDN 캐시)]
     ↓
[HLS Output: m3u8 + ts]
     ↓
[Player (브라우저, 모바일, TV)]

```

### 1. 실시간 영상 입력 (라이브 스트림 수신)

- **RTMP** 또는 **WebRTC**로 스트림을 수신합니다.
- Go로 직접 구현해도 되지만, 대부분은 `nginx-rtmp-module`, `MediaSoup`, `Pion (Go WebRTC)` 같은 툴을 사용합니다.

✅ Twitch도 RTMP 입력을 받아 ffmpeg로 처리합니다.

### 2. Transcoding 및 Segmenting

- 수신된 스트림은 **FFmpeg** 등을 사용해 HLS 형식(`.m3u8 + .ts`)으로 변환됩니다.

```bash
$ ffmpeg -i rtmp://your/input \
  -c:v libx264 -c:a aac -f hls \
  -hls_time 4 -hls_list_size 5 -hls_flags delete_segments \
  /path/to/output/stream.m3u8
```

### 3. HLS Segment 저장 및 서빙

- 생성된 `.ts` 조각과 `.m3u8`은 클라이언트에 제공되어야 하며, 일반적으로:

|방식|설명|
|---|---|
|로컬 NGINX or Go 서버|ts/m3u8을 로컬 파일로 저장 후 바로 서빙|
|CDN 연동 (S3, CloudFront 등)|ts/m3u8을 업로드 후 CDN으로 배포|
|Redis or MemoryFS|짧은 시간 동안 메모리에서 빠르게 제공 (지연 최소화)|

### 4. Go로 구성할 수 있는 부분들

|기능|구현 방식|
|---|---|
|RTMP/WebRTC 수신|`pion/webrtc`, `livekit`, `mediasoup`, `nginx-rtmp` 연동|
|FFmpeg 제어|Go에서 `exec.CommandContext()`로 `ffmpeg` 트랜스코딩 실행|
|HLS 서버|Go HTTP 서버로 `m3u8`, `ts` 파일 서빙|
|Segment 관리|HLS segment를 메모리 또는 디스크에 저장/삭제 관리|
|Session 관리|유저별 스트림 상태 및 뷰어 수 추적|
|인증 / 채팅|스트리밍 인증, 채팅, 도네이션, 구독 등 부가 기능|



### 5. 최적화

- `hls_time`은 보통 2~4초 사이로 설정 (지연 최소화 목적).
- `hls_list_size`는 플레이어가 가져갈 segment 수 (보통 3~5).
- `.ts` 파일은 용량이 크므로, 빠르게 삭제하거나 CDN에 offload.
- 유저가 많은 경우 **multi-bitrate (adaptive bitrate streaming)** 을 위해 `ffmpeg`로 여러 해상도 동시에 생성 필요.



---

## Reference

- [Http-Live-Streaming](https://www.cloudflare.com/ko-kr/learning/video/what-is-http-live-streaming/) 
- [go WebRTC Pion](https://github.com/pion/webrtc) 
