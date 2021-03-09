
import { makeStyles } from '@material-ui/core/styles';
import AddIcon from '@material-ui/icons/Add';
import DeleteIcon from '@material-ui/icons/Delete';
import Button from '@material-ui/core/Button';

const useStyles = makeStyles((theme) => ({
    buttons: {
        display: "flex",
        justifyContent: "space-evenly",
        padding: 10,

    }
}));

export default function TopButtons({ numElemsSelected, handleDelete, setOpen }) {
    const classes = useStyles();
    return (
        <div className={classes.buttons}>
            <Button
                variant="outlined"
                color="secondary"
                // className={classes.button}
                startIcon={<DeleteIcon />}
                onClick={() => {
                    handleDelete()
                }}
                disabled={numElemsSelected === 0 ? true : false}
            >
                Delete
      </Button>
            <Button
                variant="outlined"
                color="primary"
                // className={classes.button}
                startIcon={<AddIcon />}
                onClick={() => setOpen(true)}
            >
                Create
      </Button>
        </div>
    )
}