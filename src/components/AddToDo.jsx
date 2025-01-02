function AddToDo() {
  return (
    <div class="container text-center">
      <div class="row ss-row">
        <div class="col-6">
          <input type="text" placeholder="Enter ToDo here" />
        </div>
        <div class="col-4">
          <input type="date" />
        </div>
        <div class="col-2">
          <button class="btn btn-success ss-button">Add</button>
        </div>
      </div>
    </div>
  );
}

export default AddToDo; 