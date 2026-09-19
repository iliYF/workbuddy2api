package server

// version 构建时经 -ldflags "-X workbuddy2api/internal/server.version=<tag>" 注入;
// 本地/未注入构建默认 "dev"。经 /healthz 的 version 字段透出。
var version = "dev"
