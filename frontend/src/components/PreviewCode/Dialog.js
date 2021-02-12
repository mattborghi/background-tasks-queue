import { Button, Dialog, DialogActions, DialogContent, DialogTitle } from '@material-ui/core';

// Import My Components
import { PreviewCode } from './PreviewCode';

export function PreviewDialog({ open, code, onClose }) {
    const handleClose = () => {
        onClose(false)
    }
    return (
        <Dialog
            open={open}
            maxWidth={'sm'}
            fullWidth
            onClose={handleClose}
            aria-labelledby="form-dialog-title"
        >
            <DialogTitle id="form-dialog-title">Preview Code</DialogTitle>
            <DialogContent dividers>
                <PreviewCode code={code} />
            </DialogContent>

            <DialogActions>
                <Button onClick={handleClose} color="primary">
                    Close
                </Button>
            </DialogActions>
        </Dialog>
    )
}