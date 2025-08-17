export interface AppSettings {
  caddyfile_path: string
  show_in_menubar: boolean
  show_in_dock: boolean
  start_with_system: boolean
}

export interface Site {
  domain: string
  port: string
  enabled?: boolean
}