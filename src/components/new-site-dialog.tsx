import { useState } from 'react'
import { Plus } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'

interface NewSiteDialogProps {
  onAddSite: (domain: string, port: string) => void
}

export function NewSiteDialog({ onAddSite }: NewSiteDialogProps) {
  const [open, setOpen] = useState(false)
  const [domain, setDomain] = useState('')
  const [port, setPort] = useState('')

  const handleSubmit = () => {
    onAddSite(domain, port)
    setDomain('')
    setPort('')
    setOpen(false)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && domain && port) {
      handleSubmit()
    }
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button variant="outline" size="icon">
          <Plus className="h-4 w-4" />
          <span className="sr-only">Add new site</span>
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Add New Site</DialogTitle>
          <DialogDescription>
            Configure a new reverse proxy mapping
          </DialogDescription>
        </DialogHeader>
        <div className="grid gap-4 py-4">
          <div className="grid gap-2">
            <Label htmlFor="domain">Domain</Label>
            <Input
              id="domain"
              placeholder="myapp or myapp.test"
              value={domain}
              onChange={(e) => setDomain(e.target.value)}
              onKeyDown={handleKeyDown}
              autoFocus
            />
          </div>
          <div className="grid gap-2">
            <Label htmlFor="port">Port</Label>
            <Input
              id="port"
              type="number"
              placeholder="3000"
              value={port}
              onChange={(e) => setPort(e.target.value)}
              onKeyDown={handleKeyDown}
            />
          </div>
        </div>
        <div className="flex justify-end">
          <Button onClick={handleSubmit} disabled={!domain || !port}>
            Add Site
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}