// React
import { useState, useEffect } from 'react'

// Tauri
import { invoke } from '@tauri-apps/api/core'
import { openUrl } from '@tauri-apps/plugin-opener'

// Icons
import { Trash2, RefreshCw, Globe, Pencil, Check, X, ExternalLink } from 'lucide-react'

// UI Components
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Card, CardContent } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { Switch } from '@/components/ui/switch'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Toaster, toast } from 'sonner'

// Components
import { ThemeToggle } from '@/components/theme-toggle'
import { SettingsDialog } from '@/components/settings-dialog'
import { NewSiteDialog } from '@/components/new-site-dialog'

// Utils
import { Site, parseCaddyfile, buildCaddyfile } from '@/lib/caddyfile'

// Styles
import './index.css'

interface ExtendedSite extends Site {
  enabled?: boolean
}

function App() {
  const [sites, setSites] = useState<ExtendedSite[]>([])
  const [, setLoading] = useState(false)
  const [editingIndex, setEditingIndex] = useState<number | null>(null)
  const [editDomain, setEditDomain] = useState('')
  const [editPort, setEditPort] = useState('')

  useEffect(() => {
    loadCaddyfile()
  }, [])

  const loadCaddyfile = async (showToast = false) => {
    try {
      setLoading(true)
      const content = await invoke<string>('read_caddyfile')
      const parsedSites = parseCaddyfile(content)
      // Add enabled state to all sites (default true)
      setSites(parsedSites.map(site => ({ ...site, enabled: true })))
      if (showToast) {
        toast.success('Caddyfile loaded')
      }
    } catch (error) {
      toast.error('Failed to load Caddyfile: ' + error)
    } finally {
      setLoading(false)
    }
  }

  const saveCaddyfile = async (updatedSites?: ExtendedSite[], showToast = true) => {
    try {
      setLoading(true)
      const sitesToSave = updatedSites || sites
      // Only save enabled sites
      const enabledSites = sitesToSave.filter(site => site.enabled)
      const content = buildCaddyfile(enabledSites)
      await invoke('write_caddyfile', { content })
      if (showToast) {
        toast.success('Caddyfile saved')
      }
    } catch (error) {
      toast.error('Failed to save Caddyfile: ' + error)
    } finally {
      setLoading(false)
    }
  }

  const addSite = async (newDomain: string, newPort: string) => {
    if (!newDomain || !newPort) {
      toast.error('Please enter both domain and port')
      return
    }
    
    const domain = newDomain.endsWith('.test') ? newDomain : `${newDomain}.test`
    const port = parseInt(newPort)
    
    if (isNaN(port)) {
      toast.error('Port must be a number')
      return
    }
    
    const newSites = [...sites, { domain, port, enabled: true }]
    setSites(newSites)
    await saveCaddyfile(newSites, false)
    toast.success('Site added')
  }

  const removeSite = async (index: number) => {
    const newSites = sites.filter((_, i) => i !== index)
    setSites(newSites)
    await saveCaddyfile(newSites, false)
    toast.success('Site removed')
  }

  const toggleSite = async (index: number) => {
    const newSites = [...sites]
    newSites[index].enabled = !newSites[index].enabled
    setSites(newSites)
    await saveCaddyfile(newSites, false)
    toast.success(`Site ${newSites[index].enabled ? 'enabled' : 'disabled'}`)
  }

  const startEditing = (index: number) => {
    setEditingIndex(index)
    setEditDomain(sites[index].domain)
    setEditPort(sites[index].port.toString())
  }

  const cancelEditing = () => {
    setEditingIndex(null)
    setEditDomain('')
    setEditPort('')
  }

  const saveEdit = async (index: number) => {
    if (!editDomain || !editPort) {
      toast.error('Domain and port cannot be empty')
      return
    }

    const port = parseInt(editPort)
    if (isNaN(port)) {
      toast.error('Port must be a number')
      return
    }

    const newSites = [...sites]
    newSites[index] = {
      ...newSites[index],
      domain: editDomain.endsWith('.test') ? editDomain : `${editDomain}.test`,
      port
    }
    setSites(newSites)
    setEditingIndex(null)
    await saveCaddyfile(newSites, false)
    toast.success('Site updated')
  }

  const reloadCaddy = async () => {
    try {
      setLoading(true)
      await invoke('reload_caddy')
      toast.success('Caddy reloaded successfully!')
    } catch (error) {
      toast.error('Failed to reload Caddy: ' + error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <TooltipProvider>
      <div className="h-screen bg-background flex flex-col">
        <Toaster position="top-right" />
      
      <div className="flex-1 container mx-auto p-6 max-w-6xl flex flex-col">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-semibold">Active Sites</h1>
          <div className="flex gap-2">
            <NewSiteDialog onAddSite={addSite} />
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="icon" className="relative">
                  <RefreshCw className="h-4 w-4" />
                  <span className="sr-only">Reload menu</span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={reloadCaddy}>
                  Reload Caddy
                </DropdownMenuItem>
                <DropdownMenuItem onClick={() => loadCaddyfile(true)}>
                  Refresh list
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
            <SettingsDialog />
            <ThemeToggle />
          </div>
        </div>
        
        <Card className="flex-1 flex flex-col overflow-hidden py-0">
          <CardContent className="flex-1 flex flex-col p-0">
                  {sites.length > 0 ? (
                    <div className="flex-1 overflow-auto">
                      <Table>
                      <TableHeader className="bg-muted/50">
                        <TableRow>
                          <TableHead>Domain</TableHead>
                          <TableHead>Port</TableHead>
                          <TableHead>Status</TableHead>
                          <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {sites.map((site, index) => (
                          <TableRow key={index}>
                            <TableCell className="font-medium">
                              {editingIndex === index ? (
                                <Input
                                  value={editDomain}
                                  onChange={(e) => setEditDomain(e.target.value)}
                                  onKeyDown={(e) => {
                                    if (e.key === 'Enter') saveEdit(index)
                                    if (e.key === 'Escape') cancelEditing()
                                  }}
                                  className="max-w-[200px]"
                                  autoFocus
                                />
                              ) : (
                                <div className="flex items-center gap-2">
                                  <Globe className="h-4 w-4 text-muted-foreground" />
                                  <a 
                                    href={`https://${site.domain}`} 
                                    target="_blank" 
                                    rel="noopener noreferrer"
                                    className="hover:underline"
                                  >
                                    {site.domain}
                                  </a>
                                </div>
                              )}
                            </TableCell>
                            <TableCell>
                              {editingIndex === index ? (
                                <Input
                                  type="number"
                                  value={editPort}
                                  onChange={(e) => setEditPort(e.target.value)}
                                  onKeyDown={(e) => {
                                    if (e.key === 'Enter') saveEdit(index)
                                    if (e.key === 'Escape') cancelEditing()
                                  }}
                                  className="max-w-[100px]"
                                />
                              ) : (
                                <Badge variant="secondary">{site.port}</Badge>
                              )}
                            </TableCell>
                            <TableCell>
                              <Switch
                                checked={site.enabled !== false}
                                onCheckedChange={() => toggleSite(index)}
                              />
                            </TableCell>
                            <TableCell className="text-right">
                              <div className="flex items-center justify-end gap-1">
                                {editingIndex === index ? (
                                  <>
                                    <Button
                                      variant="ghost"
                                      size="sm"
                                      onClick={() => saveEdit(index)}
                                    >
                                      <Check className="h-4 w-4" />
                                    </Button>
                                    <Button
                                      variant="ghost"
                                      size="sm"
                                      onClick={cancelEditing}
                                    >
                                      <X className="h-4 w-4" />
                                    </Button>
                                  </>
                                ) : (
                                  <>
                                    <Tooltip>
                                      <TooltipTrigger asChild>
                                        <Button
                                          variant="ghost"
                                          size="sm"
                                          onClick={() => openUrl(`https://${site.domain}`)}
                                        >
                                          <ExternalLink className="h-4 w-4" />
                                        </Button>
                                      </TooltipTrigger>
                                      <TooltipContent>
                                        <p>Open in browser</p>
                                      </TooltipContent>
                                    </Tooltip>
                                    <Button
                                      variant="ghost"
                                      size="sm"
                                      onClick={() => startEditing(index)}
                                    >
                                      <Pencil className="h-4 w-4" />
                                    </Button>
                                    <Button
                                      variant="ghost"
                                      size="sm"
                                      onClick={() => removeSite(index)}
                                    >
                                      <Trash2 className="h-4 w-4" />
                                    </Button>
                                  </>
                                )}
                              </div>
                            </TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                    </div>
                  ) : (
                    <div className="p-6">
                      <Alert>
                        <AlertDescription>
                          No sites configured. Click the + button to add your first site.
                        </AlertDescription>
                      </Alert>
                    </div>
                  )}
                </CardContent>
              </Card>
      </div>
      </div>
    </TooltipProvider>
  )
}

export default App