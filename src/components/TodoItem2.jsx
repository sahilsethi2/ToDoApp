function ToDoItem2() {
    let todoName = 'Go to college';
    let todoDate = '1/1/2025';

  return (
    <div className="container">
    <div class="row ss-row">
      <div class="col-6">{todoName}</div>
      <div class="col-4">{todoDate}</div>
      <div class="col-2">
        <button class="btn btn-danger ss-button">Delete</button>
      </div>
    </div>
    </div>
  );
}

export default ToDoItem2;
