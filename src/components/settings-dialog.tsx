// React
import { useState, useEffect, useRef } from 'react'

// Icons
import { Settings, Download, Trash2, FolderOpen } from 'lucide-react'

// Types
import type { AppSettings } from '@/types'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { toast } from 'sonner'
import { invoke } from '@tauri-apps/api/core'

export function SettingsDialog() {
  const [caddyfilePath, setCaddyfilePath] = useState('')
  const [showInMenubar, setShowInMenubar] = useState(false)
  const [showInDock, setShowInDock] = useState(true)
  const [startWithSystem, setStartWithSystem] = useState(false)
  const [caddyInstalled, setCaddyInstalled] = useState(false)
  const [loading, setLoading] = useState(false)
  const [isCheckingAutostart, setIsCheckingAutostart] = useState(false)
  const pathSaveTimeout = useRef<number | null>(null)

  useEffect(() => {
    loadSettings()
    checkCaddyInstalled()
  }, [])

  const loadSettings = async () => {
    try {
      const settings = await invoke<AppSettings>('get_settings')
      setCaddyfilePath(settings.caddyfile_path || '~/caddy/Caddyfile')
      setShowInMenubar(settings.show_in_menubar || false)
      setShowInDock(settings.show_in_dock !== false)
      setStartWithSystem(settings.start_with_system || false)
      
      // Check actual autostart status
      checkAutostartStatus()
      
      // If system tray was enabled, re-enable it
      if (settings.show_in_menubar) {
        await invoke('enable_system_tray')
      }
    } catch (error) {
      console.error('Failed to load settings:', error)
    }
  }

  // Settings are auto-saved in each handler, no need for separate save function


  const handleMenubarChange = async (checked: boolean) => {
    setShowInMenubar(checked)
    try {
      if (checked) {
        await invoke('enable_system_tray')
      } else {
        await invoke('disable_system_tray')
      }
      await invoke('save_settings', {
        settings: {
          caddyfile_path: caddyfilePath,
          show_in_menubar: checked,
          show_in_dock: showInDock,
          start_with_system: startWithSystem,
        }
      })
    } catch (error) {
      toast.error('Failed to update menu bar setting')
    }
  }

  const handleDockChange = async (checked: boolean) => {
    setShowInDock(checked)
    try {
      await invoke('set_dock_visibility', { visible: checked })
      await invoke('save_settings', {
        settings: {
          caddyfile_path: caddyfilePath,
          show_in_menubar: showInMenubar,
          show_in_dock: checked,
          start_with_system: startWithSystem,
        }
      })
    } catch (error) {
      toast.error('Failed to update dock setting')
    }
  }


  const checkAutostartStatus = async () => {
    try {
      setIsCheckingAutostart(true)
      // Check if autostart is actually enabled
      const { isEnabled } = await import('@tauri-apps/plugin-autostart')
      const enabled = await isEnabled()
      setStartWithSystem(enabled)
    } catch (error) {
      console.error('Failed to check autostart status:', error)
    } finally {
      setIsCheckingAutostart(false)
    }
  }

  const handleAutostartChange = async (checked: boolean) => {
    setStartWithSystem(checked)
    try {
      const { enable, disable } = await import('@tauri-apps/plugin-autostart')
      if (checked) {
        await enable()
      } else {
        await disable()
      }
      await invoke('save_settings', {
        settings: {
          caddyfile_path: caddyfilePath,
          show_in_menubar: showInMenubar,
          show_in_dock: showInDock,
          start_with_system: checked,
        }
      })
    } catch (error) {
      toast.error('Failed to update startup setting')
      // Revert state on error
      setStartWithSystem(!checked)
    }
  }

  const handleCaddyfilePathChange = async (value: string) => {
    setCaddyfilePath(value)
    // Debounce the save
    if (pathSaveTimeout.current) {
      clearTimeout(pathSaveTimeout.current)
    }
    pathSaveTimeout.current = setTimeout(async () => {
      try {
        await invoke('save_settings', {
          settings: {
            caddyfile_path: value,
            show_in_menubar: showInMenubar,
            show_in_dock: showInDock,
            start_with_system: startWithSystem,
          }
        })
      } catch (error) {
        console.error('Failed to save path:', error)
      }
    }, 500)
  }

  const checkCaddyInstalled = async () => {
    try {
      const installed = await invoke<boolean>('check_caddy_installed')
      setCaddyInstalled(installed)
    } catch (error) {
      setCaddyInstalled(false)
    }
  }

  const installCaddy = async () => {
    try {
      setLoading(true)
      await invoke('install_caddy')
      setCaddyInstalled(true)
      toast.success('Caddy installed successfully')
    } catch (error) {
      toast.error('Failed to install Caddy: ' + error)
    } finally {
      setLoading(false)
    }
  }

  const uninstallCaddy = async () => {
    if (!confirm('Are you sure you want to uninstall Caddy? This will remove Caddy from your system.')) {
      return
    }
    
    try {
      setLoading(true)
      await invoke('uninstall_caddy')
      setCaddyInstalled(false)
      toast.success('Caddy uninstalled successfully')
    } catch (error) {
      toast.error('Failed to uninstall Caddy: ' + error)
    } finally {
      setLoading(false)
    }
  }

  const selectCaddyfile = async () => {
    try {
      const selected = await invoke<string>('select_caddyfile')
      if (selected) {
        setCaddyfilePath(selected)
      }
    } catch (error) {
      // Expected for now - file dialog not implemented
      toast.info('Please type the file path manually')
    }
  }

  const uninstallApp = async () => {
    if (!confirm('Are you sure you want to uninstall Caddy GUI? This will:\n\n• Delete all settings\n• Remove auto-start configuration\n\nAfter this, drag the app to Trash to complete uninstall.')) {
      return
    }
    
    try {
      setLoading(true)
      const message = await invoke<string>('uninstall_app')
      toast.success(message)
      setLoading(false)
    } catch (error) {
      toast.error('Failed to uninstall: ' + error)
      setLoading(false)
    }
  }

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline" size="icon">
          <Settings className="h-4 w-4" />
          <span className="sr-only">Settings</span>
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[475px]">
        <DialogHeader>
          <DialogTitle>Settings</DialogTitle>
        </DialogHeader>
        
        <Tabs defaultValue="caddy" className="mt-4">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="caddy">Caddy</TabsTrigger>
            <TabsTrigger value="interface">Interface</TabsTrigger>
          </TabsList>
          
          <TabsContent value="caddy" className="space-y-4 mt-4">
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="caddyfile">Caddyfile Path</Label>
                <div className="flex gap-2">
                  <Input
                    id="caddyfile"
                    value={caddyfilePath}
                    onChange={(e) => handleCaddyfilePathChange(e.target.value)}
                    placeholder="~/caddy/Caddyfile"
                  />
                  <Button
                    variant="outline"
                    size="icon"
                    onClick={selectCaddyfile}
                  >
                    <FolderOpen className="h-4 w-4" />
                  </Button>
                </div>
              </div>
              
              <div className="space-y-2">
                <Label>Status</Label>
                <div className="text-sm text-muted-foreground">
                  {caddyInstalled ? (
                    <span className="text-green-600 dark:text-green-400">Caddy is installed</span>
                  ) : (
                    <span className="text-yellow-600 dark:text-yellow-400">Caddy is not installed</span>
                  )}
                </div>
                {!caddyInstalled ? (
                  <Button
                    onClick={installCaddy}
                    disabled={loading}
                    className="w-full"
                  >
                    <Download className="h-4 w-4 mr-2" />
                    Install Caddy
                  </Button>
                ) : (
                  <Button
                    variant="outline"
                    onClick={uninstallCaddy}
                    disabled={loading}
                    className="w-full"
                  >
                    <Trash2 className="h-4 w-4 mr-2" />
                    Uninstall Caddy
                  </Button>
                )}
              </div>
            </div>
          </TabsContent>
          
          <TabsContent value="interface" className="space-y-4 mt-4">
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <Label htmlFor="menubar">System tray</Label>
                <Switch
                  id="menubar"
                  checked={showInMenubar}
                  onCheckedChange={handleMenubarChange}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label htmlFor="dock">Show in Dock</Label>
                <Switch
                  id="dock"
                  checked={showInDock}
                  onCheckedChange={handleDockChange}
                />
              </div>
              
              <div className="flex items-center justify-between">
                <Label htmlFor="autostart">Launch at startup</Label>
                <Switch
                  id="autostart"
                  checked={startWithSystem}
                  onCheckedChange={handleAutostartChange}
                  disabled={isCheckingAutostart}
                />
              </div>
              
              <div className="pt-4 space-y-2">
                <Button
                  variant="destructive"
                  onClick={uninstallApp}
                  disabled={loading}
                  className="w-full"
                >
                  <Trash2 className="h-4 w-4 mr-2" />
                  Uninstall App
                </Button>
              </div>
            </div>
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  )
}