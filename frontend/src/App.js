import { useState } from 'react'
import './App.css';
// Material UI - Main components
import { makeStyles } from '@material-ui/core/styles';
import { Typography, Chip, IconButton } from '@material-ui/core';
import { DataGrid } from '@material-ui/data-grid';
import MuiAlert from '@material-ui/lab/Alert';
// Material UI - Icons
import DoneIcon from '@material-ui/icons/Done';
import HourglassEmptyIcon from '@material-ui/icons/HourglassEmpty';
import AutorenewIcon from '@material-ui/icons/Autorenew';
import CloseIcon from '@material-ui/icons/Close';
import CodeIcon from '@material-ui/icons/Code';
// Apollo Client
import { useQuery, useMutation } from '@apollo/client';
// Other packages
import { MetroSpinner } from "react-spinners-kit";

// Load our components
import NewTestDialog from './components/NewTestDialog';
import TopButtons from './components/TopButtons';
import CustomNoRowsOverlay from './components/NoRowsOverlay';
import GitHub from './components/GitHub/GitHub';
import { PreviewDialog } from './components/PreviewCode/Dialog';

// Load graphql queries
import { GET_ALL_RESULTS } from './graphql/query'
import { CREATE_RESULT, DELETE_RESULT } from './graphql/mutation'


const useStyles = makeStyles((theme) => ({
  title: {
    textAlign: "center",
  },
  spinner: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100vh'
  },
  chip: {
    '& .MuiChip-label': {
      minWidth: "85px"
      // fontWeight: "bolder",
    },
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

function App() {
  const classes = useStyles();
  const [name, setName] = useState("")
  const [code, setCode] = useState("")
  const [open, setOpen] = useState(false)
  const [openCode, setOpenCode] = useState(false)
  const [previewCode, setPreviewCode] = useState("")
  const [selected, setSelected] = useState([])
  const { loading, error, data, refetch } = useQuery(GET_ALL_RESULTS, {
    pollInterval: 500,
  });


  const getChip = status => {
    var badge = (function (status) {
      switch (status) {
        case "FINISHED":
          return <DoneIcon />
        case "QUEUEING":
          return <HourglassEmptyIcon />
        case "RUNNING":
          return <AutorenewIcon />
        case "FAILED":
          return <CloseIcon />
        default:
          return <p>Wrong Status Code!</p>
      }
    })(status)
    return <Chip
      className={classes.chip}
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
    },
    {
      field: 'name',
      headerName: 'Name',
      flex: 1,
    },
    {
      field: 'code',
      headerName: 'Code',
      flex: 0.5,
      renderCell: params => {
        return (
          <label htmlFor="icon-button-file">
            <IconButton color="secondary" aria-label="preview code" component="span" onClick={() => {
              setPreviewCode(params.value)
              setOpenCode(true)
            }}>
              <CodeIcon />
            </IconButton>
          </label>
        )
      }
    },
    {
      field: 'value',
      headerName: 'Value',
      type: 'number',
      flex: 0.5,
      renderCell: params => {
        return params.value === null ? "-" : params.value.toExponential(4);
      },
    },
    {
      field: 'status',
      headerName: 'Status',
      flex: 0.5,
      renderCell: params => (
        getChip(params.value)
      ),
    },
    {
      field: 'createdAt',
      headerName: 'Created At',
      description: 'Date and time of creation.',
      sortable: true,
      type: 'dateTime',
      flex: 1,
      renderCell: params => {
        let date = new Date(params.value)
        return <p>{date.toUTCString()}</p>
      }
    },
  ];


  const [deleteResult] = useMutation(DELETE_RESULT, {
    onCompleted: data => {
      setSelected([])
    },
    update: (cache, result) => handleUpdateCache(cache, result)
  });

  const [createResult] = useMutation(CREATE_RESULT, {
    onCompleted: data => {
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

  const handleDelete = () => {
    selected.forEach(id => {
      // Remove selected rows
      deleteResult({ variables: { resultId: id } })
    })
  }

  const handleCreate = () => {
    // Create result
    createResult({ variables: { name, code } })
    // We can move this to completed inside useMutation
    setName("")
    setCode("")
    setOpen(false)
  }

  const Alert = (props) => {
    return <MuiAlert elevation={6} variant="filled" {...props} />;
  }

  if (loading) return <div className={classes.spinner}> <MetroSpinner size={60} color="SlateGrey" loading={loading} /></div>;
  if (error) return <Alert severity="error">{error.message}</Alert>;


  return (
    <div>

      <Typography className={classes.title} variant="h2" component="h2">
        Test Runs
      </Typography>

      <TopButtons numElemsSelected={selected.length} handleDelete={handleDelete} setOpen={setOpen} />

      {/* Table */}
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
          rows={data ? data.results : []}
          columns={columns}
          onSelectionModelChange={e => {
            setSelected(e.selectionModel)
          }}
          components={{
            noRowsOverlay: CustomNoRowsOverlay,
          }}
        />
      </div>

      {/* Github ribbon */}
      <GitHub />

      { openCode && <PreviewDialog code={previewCode} open={openCode} onClose={setOpenCode} />}

      {/* PopUp window */}
      <NewTestDialog
        open={open}
        name={name}
        code={code}
        setName={setName}
        setCode={setCode}
        setOpen={setOpen}
        handleCreate={handleCreate}
      />

    </div>
  );
}

export default App;
