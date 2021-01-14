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
import Chip from '@material-ui/core/Chip';
import DoneIcon from '@material-ui/icons/Done';
import HourglassFullIcon from '@material-ui/icons/HourglassFull';
import AutorenewIcon from '@material-ui/icons/Autorenew';
import CustomNoRowsOverlay from './NoRowsOverlay'

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
  root: {
    '& .MuiDataGrid-colCellTitle': {
      display: "block",
      textAlign: "center",
      width: "100%",
      fontWeight: "bolder",
      fontSize: 16,
    },
    '& .MuiCheckbox-root svg': {
      width: 16,
      height: 16,
      backgroundColor: 'transparent',
      border: `1px solid ${theme.palette.type === 'light' ? '#d9d9d9' : 'rgb(67, 67, 67)'
        }`,
      borderRadius: 2,
    },
    '& .MuiCheckbox-root svg path': {
      display: 'none',
    },
    '& .MuiCheckbox-root.Mui-checked:not(.MuiCheckbox-indeterminate) svg': {
      backgroundColor: '#1890ff',
      borderColor: '#1890ff',
    },
    '& .MuiCheckbox-root.Mui-checked .MuiIconButton-label:after': {
      position: 'absolute',
      display: 'table',
      border: '2px solid #fff',
      borderTop: 0,
      borderLeft: 0,
      transform: 'rotate(45deg) translate(-50%,-50%)',
      opacity: 1,
      transition: 'all .2s cubic-bezier(.12,.4,.29,1.46) .1s',
      content: '""',
      top: '50%',
      left: '39%',
      width: 5.71428571,
      height: 9.14285714,
    },
    '& .MuiCheckbox-root.MuiCheckbox-indeterminate .MuiIconButton-label:after': {
      width: 8,
      height: 8,
      backgroundColor: '#1890ff',
      transform: 'none',
      top: '39%',
      border: 0,
    },
    border: 0,
    color:
      theme.palette.type === 'light' ? 'rgba(0,0,0,.85)' : 'rgba(255,255,255,0.85)',
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif',
      '"Apple Color Emoji"',
      '"Segoe UI Emoji"',
      '"Segoe UI Symbol"',
    ].join(','),
    WebkitFontSmoothing: 'auto',
    letterSpacing: 'normal',
    '& .MuiDataGrid-columnsContainer': {
      backgroundColor: theme.palette.type === 'light' ? '#fafafa' : '#1d1d1d',
    },
    '& .MuiDataGrid-iconSeparator': {
      display: 'none',
    },
    '& .MuiDataGrid-colCell, .MuiDataGrid-cell': {
      borderRight: `1px solid ${theme.palette.type === 'light' ? '#f0f0f0' : '#303030'
        }`,
    },
    '& .MuiDataGrid-columnsContainer, .MuiDataGrid-cell': {
      borderBottom: `1px solid ${theme.palette.type === 'light' ? '#f0f0f0' : '#303030'
        }`,
    },
    '& .MuiDataGrid-cell': {
      textAlign: "center",
      justifyContent: "center",
      color:
        theme.palette.type === 'light'
          ? 'rgba(0,0,0,.85)'
          : 'rgba(255,255,255,0.65)',
    },
    '& .MuiPaginationItem-root': {
      borderRadius: 0,
    },
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


const getChip = status => {
  var badge = (function (status) {
    switch (status) {
      case "FINISHED":
        return <DoneIcon />
      case "QUEUEING":
        return <HourglassFullIcon />
      case "RUNNING":
        return <AutorenewIcon />
      default:
        return <p>Wrong Status Code!</p>
    }
  })(status)
  return <Chip
    avatar={badge}
    label={status}
    variant="outlined"
  />
}


const columns = [
  {
    field: 'id',
    headerName: 'ID',
    width: 150,
    // align: "center",
  },
  {
    field: 'name',
    headerName: 'Name',
    // width: 120,
    flex: 1,
    // align: "center",
  },
  {
    field: 'value',
    headerName: 'Value',
    type: 'number',
    // width: 100,
    flex: 0.5,
    // align: "center",
  },
  {
    field: 'status',
    headerName: 'Status',
    // width: 120,
    flex: 0.5,
    // headerAlign: 'center',
    renderCell: params => (
      getChip(params.value)
    ),
    // align: "center",
  },
  {
    field: 'createdAt',
    headerName: 'Created At',
    description: 'Date and time of creation.',
    sortable: true,
    type: 'dateTime',
    // width: 160,
    flex: 1,
    renderCell: params => {
      let date = new Date(params.value)
      return <p>{date.toUTCString()}</p>
    }
    // align: "center",
  },
];

function App() {
  const classes = useStyles();
  const [name, setName] = useState("")
  const [open, setOpen] = useState(false)
  const [selected, setSelected] = useState([])
  const { loading, error, data, refetch } = useQuery(GET_ALL_RESULTS, {
    pollInterval: 500,
  });
  const [deleteResult] = useMutation(DELETE_RESULT, {
    onCompleted: data => {
      setSelected([])
      // refetch()
    },
    update: (cache, result) => handleUpdateCache(cache, result)
  });

  const [createResult] = useMutation(CREATE_RESULT, {
    onCompleted: data => {
      // setSelected([])
      refetch()
    },
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

  // const handleClick = ({ data, isSelected }) => {
  //   console.log("Selected row: ", data.id)
  //   // console.log("Selected: ", isSelected)
  //   if (isSelected) {
  //     setSelected([...selected, data.id])
  //   } else {
  //     setSelected(selected.filter(function (e) { return e !== data.id }))
  //   }
  // };

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
          variant="outlined"
          color="secondary"
          className={classes.button}
          startIcon={<DeleteIcon />}
          onClick={() => handleDelete()}
        >
          Delete
      </Button>
        <Button
          variant="outlined"
          color="primary"
          className={classes.button}
          startIcon={<AddIcon />}
          onClick={() => setOpen(true)}
        >
          Create
      </Button>
      </div>
      <div style={{ height: 800, width: '100%', }}>
        <DataGrid
          className={classes.root}
          hideFooterPagination
          showToolbar
          hideFooterRowCount
          disableSelectionOnClick
          autoHeight
          checkboxSelection
          rowsPerPageOptions={[]}
          rows={data.results}
          columns={columns}
          // onRowSelected={e => handleClick(e)}
          // onColumnHeaderClick={e => handleCheckboxHeader(e)}
          onSelectionChange={e => setSelected(e.rowIds)}
          components={{
            noRowsOverlay: CustomNoRowsOverlay,
          }}
        />
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
