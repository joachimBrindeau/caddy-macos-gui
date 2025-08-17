use std::fs;
use std::path::PathBuf;
use std::process::Command;
use serde::{Deserialize, Serialize};
use tauri::menu::{MenuBuilder, MenuItemBuilder, SubmenuBuilder};
use tauri::tray::TrayIconBuilder;
use tauri::Manager;

#[derive(Debug, Serialize, Deserialize)]
struct AppSettings {
    caddyfile_path: String,
    show_in_menubar: bool,
    show_in_dock: bool,
    start_with_system: bool,
}

#[tauri::command]
fn read_caddyfile() -> Result<String, String> {
    let home = std::env::var("HOME").map_err(|e| e.to_string())?;
    let caddyfile_path = PathBuf::from(home).join("caddy").join("Caddyfile");
    
    fs::read_to_string(caddyfile_path)
        .map_err(|e| format!("Failed to read Caddyfile: {}", e))
}

#[tauri::command]
fn write_caddyfile(content: String) -> Result<(), String> {
    let home = std::env::var("HOME").map_err(|e| e.to_string())?;
    let caddyfile_path = PathBuf::from(home).join("caddy").join("Caddyfile");
    
    fs::write(caddyfile_path, content)
        .map_err(|e| format!("Failed to write Caddyfile: {}", e))
}

#[tauri::command]
fn reload_caddy() -> Result<String, String> {
    let home = std::env::var("HOME").map_err(|e| e.to_string())?;
    let caddyfile_path = PathBuf::from(home).join("caddy").join("Caddyfile");
    
    let output = Command::new("caddy")
        .arg("reload")
        .arg("--config")
        .arg(caddyfile_path)
        .output()
        .map_err(|e| format!("Failed to execute caddy reload: {}", e))?;
    
    if output.status.success() {
        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    } else {
        Err(String::from_utf8_lossy(&output.stderr).to_string())
    }
}

#[tauri::command]
fn get_settings() -> Result<AppSettings, String> {
    let home = std::env::var("HOME").map_err(|e| e.to_string())?;
    let settings_path = PathBuf::from(&home).join(".caddy-gui").join("settings.json");
    
    if settings_path.exists() {
        let content = fs::read_to_string(settings_path)
            .map_err(|e| format!("Failed to read settings: {}", e))?;
        serde_json::from_str(&content)
            .map_err(|e| format!("Failed to parse settings: {}", e))
    } else {
        Ok(AppSettings {
            caddyfile_path: format!("{}/caddy/Caddyfile", home),
            show_in_menubar: false,
            show_in_dock: true,
            start_with_system: false,
        })
    }
}

#[tauri::command]
fn save_settings(settings: AppSettings) -> Result<(), String> {
    let home = std::env::var("HOME").map_err(|e| e.to_string())?;
    let settings_dir = PathBuf::from(&home).join(".caddy-gui");
    
    fs::create_dir_all(&settings_dir)
        .map_err(|e| format!("Failed to create settings directory: {}", e))?;
    
    let settings_path = settings_dir.join("settings.json");
    let content = serde_json::to_string_pretty(&settings)
        .map_err(|e| format!("Failed to serialize settings: {}", e))?;
    
    fs::write(settings_path, content)
        .map_err(|e| format!("Failed to write settings: {}", e))
}

#[tauri::command]
fn check_caddy_installed() -> Result<bool, String> {
    let output = Command::new("which")
        .arg("caddy")
        .output()
        .map_err(|e| format!("Failed to check caddy: {}", e))?;
    
    Ok(output.status.success())
}

#[tauri::command]
fn install_caddy() -> Result<String, String> {
    let output = Command::new("brew")
        .args(&["install", "caddy"])
        .output()
        .map_err(|e| format!("Failed to install caddy: {}", e))?;
    
    if output.status.success() {
        Ok("Caddy installed successfully".to_string())
    } else {
        Err(String::from_utf8_lossy(&output.stderr).to_string())
    }
}

#[tauri::command]
fn uninstall_caddy() -> Result<String, String> {
    // Stop caddy first
    Command::new("caddy")
        .arg("stop")
        .output()
        .ok();
    
    // Uninstall via brew
    let output = Command::new("brew")
        .args(&["uninstall", "caddy"])
        .output()
        .map_err(|e| format!("Failed to uninstall caddy: {}", e))?;
    
    if output.status.success() {
        Ok("Caddy uninstalled successfully".to_string())
    } else {
        Err(String::from_utf8_lossy(&output.stderr).to_string())
    }
}

#[tauri::command]
fn enable_system_tray(app_handle: tauri::AppHandle) -> Result<(), String> {
    // Check if tray already exists
    if app_handle.tray_by_id("main").is_some() {
        return Ok(());
    }
    
    // KISS: Simple tray creation
    tauri::tray::TrayIconBuilder::with_id("main")
        .build(&app_handle)
        .map_err(|e| e.to_string())?;
    
    Ok(())
}

#[tauri::command]
fn disable_system_tray(app_handle: tauri::AppHandle) -> Result<(), String> {
    app_handle.remove_tray_by_id("main");
    Ok(())
}

#[tauri::command]
fn set_dock_visibility(visible: bool, app_handle: tauri::AppHandle) -> Result<(), String> {
    #[cfg(target_os = "macos")]
    {
        use tauri::ActivationPolicy;
        if visible {
            let _ = app_handle.set_activation_policy(ActivationPolicy::Regular);
        } else {
            let _ = app_handle.set_activation_policy(ActivationPolicy::Accessory);
        }
    }
    Ok(())
}

// Autostart is now handled directly by the frontend plugin

#[tauri::command]
fn select_caddyfile(_app_handle: tauri::AppHandle) -> Result<String, String> {
    // For now, just return empty to indicate no selection
    // A proper file dialog would require the dialog plugin
    Err("File selection not implemented. Please type the path manually.".to_string())
}

#[tauri::command]
fn uninstall_app(app_handle: tauri::AppHandle) -> Result<String, String> {
    // Disable autostart
    use tauri_plugin_autostart::ManagerExt;
    let _ = app_handle.autolaunch().disable();
    
    // Remove settings directory
    let home = std::env::var("HOME").map_err(|e| e.to_string())?;
    let settings_dir = PathBuf::from(&home).join(".caddy-gui");
    if settings_dir.exists() {
        fs::remove_dir_all(settings_dir).ok();
    }
    
    Ok("App settings cleared. Please drag the app to Trash to complete uninstall.".to_string())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_autostart::init(tauri_plugin_autostart::MacosLauncher::LaunchAgent, None))
        .setup(|app| {
            let handle = app.handle();
            
            // Build the menu
            let reload = MenuItemBuilder::with_id("reload", "Reload App")
                .accelerator("CmdOrCtrl+R")
                .build(app)?;
            
            let quit = MenuItemBuilder::with_id("quit", "Quit")
                .accelerator("CmdOrCtrl+Q")
                .build(app)?;
            
            let app_menu = SubmenuBuilder::new(handle, "Caddy Interface")
                .item(&reload)
                .separator()
                .item(&quit)
                .build()?;
            
            let menu = MenuBuilder::new(app)
                .item(&app_menu)
                .copy()
                .paste()
                .cut()
                .undo()
                .redo()
                .select_all()
                .minimize()
                .close_window()
                .build()?;
            
            app.set_menu(menu)?;
            
            // Handle menu events
            app.on_menu_event(move |app, event| {
                match event.id().as_ref() {
                    "reload" => {
                        if let Some(window) = app.get_webview_window("main") {
                            window.eval("window.location.reload()").unwrap();
                        }
                    }
                    "quit" => {
                        app.exit(0);
                    }
                    _ => {}
                }
            });
            
            // Check settings and create tray if previously enabled
            if let Ok(settings) = get_settings() {
                if settings.show_in_menubar {
                    let _ = TrayIconBuilder::with_id("main").build(app);
                }
            }
            
            Ok(())
        })
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![
            read_caddyfile,
            write_caddyfile,
            reload_caddy,
            get_settings,
            save_settings,
            check_caddy_installed,
            install_caddy,
            uninstall_caddy,
            enable_system_tray,
            disable_system_tray,
            set_dock_visibility,
            select_caddyfile,
            uninstall_app
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}