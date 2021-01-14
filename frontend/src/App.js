import { useState } from 'react'
import './App.css';
import { AddIcon, DataGrid } from '@material-ui/data-grid';
import { useQuery, useMutation, gql } from '@apollo/client';
import { makeStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import DeleteIcon from '@material-ui/icons/Delete';
import TextField from '@material-ui/core/TextField';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';

const useStyles = makeStyles((theme) => ({
  margin: {
    margin: theme.spacing(1),
  },
  extendedIcon: {
    marginRight: theme.spacing(1),
  },
  buttons: {
    display: "flex",
    justifyContent: "space-evenly",
    padding: 10,
    
  },
}));

const GET_ALL_RESULTS = gql`
{
	results {
        id
        name
        value
        createdAt
        status
  }
}
`;

const DELETE_RESULT = gql`
mutation($resultId: Int!) {
  deleteResult(resultId: $resultId) {
    resultId
  }
}
`;

const CREATE_RESULT = gql`
mutation($name: String!) {
  createResult(name: $name) {
    result {
      id
      name
      value
      createdAt
      status
    }
  }
}
`;

const columns = [
  { field: 'id', headerName: 'ID', width: 70 },
  { field: 'name', headerName: 'Name', width: 130 },
  { field: 'value', headerName: 'Value', type: 'number', width: 100 },
  {
    field: 'status',
    headerName: 'Status',
    width: 120,
  },
  {
    field: 'createdAt',
    headerName: 'Created At',
    description: 'Date and time of creation.',
    sortable: true,
    width: 160,
  },
];

function App() {
  const classes = useStyles();
  const [name, setName] = useState("")
  const [open, setOpen] = useState(false)
  const [selected, setSelected] = useState([])
  const { loading, error, data } = useQuery(GET_ALL_RESULTS, {
    pollInterval: 500,
  });
  const [deleteResult] = useMutation(DELETE_RESULT, {
    onCompleted: data => {
      setSelected([])
    },
    update: (cache, result) => handleUpdateCache(cache, result)
  });

  const [createResult] = useMutation(CREATE_RESULT, {
    // onCompleted: data => {
    //   setSelected([])
    // },
    update: (cache, result) => handleUpdateCreateCache(cache, result)
  });


  const handleUpdateCache = (cache, { data: { deleteResult } }) => {
    const data = cache.readQuery({
      query: GET_ALL_RESULTS,
    });
    const index = data.results.findIndex(
      result => Number(result.id) === deleteResult.resultId
    );
    const results = [
      ...data.results.slice(0, index),
      ...data.results.slice(index + 1)
    ];
    cache.writeQuery({
      query: GET_ALL_RESULTS,
      data: { results }
    });
  };

  const handleUpdateCreateCache = (cache, { data: { createResult } }) => {
    const data = cache.readQuery({
      query: GET_ALL_RESULTS,
    });
    const results = data.results.concat(createResult.result);
    cache.writeQuery({
      query: GET_ALL_RESULTS,
      data: { results }
    });
  };

  const handleClick = ({ data, isSelected }) => {
    // console.log(data)
    // console.log("Selected: ", isSelected)
    if (isSelected) {
      setSelected([...selected, data.id])
    } else {
      setSelected(selected.filter(function (e) { return e !== data.id }))
    }
  };

  const handleClose = () => setOpen(false)

  const handleDelete = () => {
    selected.forEach(id => {
      // Remove selected rows
      // console.log("Deleting result with id: ", id)
      deleteResult({ variables: { resultId: id } })
    })
  }

  const handleCreate = () => {
    // Create result
    // console.log(name)
    createResult({ variables: { name } })
    // We can move this to completed inside useMutation
    setName("")
    setOpen(false)
  }

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error :(</p>;

  return (
    <>
      <div className={classes.buttons}>
        <Button
          variant="contained"
          color="secondary"
          className={classes.button}
          startIcon={<DeleteIcon />}
          onClick={() => handleDelete()}
        >
          Delete
      </Button>
        <Button
          variant="contained"
          color="primary"
          className={classes.button}
          startIcon={<AddIcon />}
          onClick={() => setOpen(true)}
      >
          Create
      </Button>
      </div>
      <div style={{ height: 400, width: '100%' }}>
        <DataGrid onRowSelected={e => handleClick(e)} disableSelectionOnClick rows={data.results} columns={columns} autoHeight rowsPerPageOptions={[]} checkboxSelection />
      </div>

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
        </DialogContent>
        <DialogActions>
          <Button onClick={handleClose} color="primary">
            Cancel
          </Button>
          <Button disabled={!name.trim()} onClick={handleCreate} color="primary">
            Create
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
}

export default App;
