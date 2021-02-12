import { Button, TextField, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle } from '@material-ui/core';

// Import My Components
import { JuliaEditor } from './AceEditor'

export default function NewTestDialog({ open, name, code, setName, setCode, setOpen, handleCreate }) {
    const handleClose = () => {
        setName("")
        setCode("")
        setOpen(false)
    }
    return (
        <Dialog open={open} onClose={handleClose} aria-labelledby="form-dialog-title">
            <DialogTitle id="form-dialog-title">Create Result</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    Complete the data to create a result.
          </DialogContentText>
                <TextField
                    autoFocus
                    margin="dense"
                    id="name"
                    label="Name"
                    fullWidth
                    onChange={e => setName(e.target.value)}
                />
                <br /><br />
                <JuliaEditor code={code} setCode={setCode} />
            </DialogContent>

            <DialogActions>
                <Button onClick={handleClose} color="primary">
                    Cancel
          </Button>
                <Button disabled={!name.trim() || !code.trim()} onClick={handleCreate} color="primary">
                    Create
          </Button>
            </DialogActions>
        </Dialog>
    )
}