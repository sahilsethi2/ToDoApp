import AppName from "./components/AppName.jsx";
import AddToDo from "./components/AddToDo.jsx";
import ToDoItem1 from "./components/TodoItem1.jsx";
import ToDoItem2 from "./components/TodoItem2.jsx";
import './App.css';

function App() {

  return (
  <center className='todo-container'>
    <AppName />
    <AddToDo />
    <div className="items-container">
    <ToDoItem1 />
    <ToDoItem2 />
    </div>
  </center>
  );
}

export default App;