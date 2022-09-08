//using Microsoft.EntityFrameworkCore;
using Dapr.Client;

var builder = WebApplication.CreateBuilder(args);
var client = new DaprClientBuilder().Build();
var store = "dapr-state";

//builder.Services.AddDbContext<TodoDb>(opt => opt.UseInMemoryDatabase("TodoList"));
builder.Services.AddSingleton<DaprClient>(client);

var app = builder.Build();
app.Urls.Add("http://+:5501");

app.MapGet( "/", () =>  $"Hello World! The time now is {DateTime.Now}" );

//app.MapGet("/todos", async (TodoDb db) => await db.Todos.ToListAsync());

app.MapGet("/todos/{id}", async (string id, DaprClient dapr) =>
    //await db.Todos.FindAsync(id)
    await dapr.GetStateAsync<Todo>(store, id)
        is Todo todo
            ? Results.Ok(todo)
            : Results.NotFound()
);

app.MapPost("/todos", async (Todo todo, DaprClient dapr) =>
{
    /*db.Todos.Add(todo);
    await db.SaveChangesAsync();*/
    await dapr.SaveStateAsync<Todo>(store, todo.Id, todo);
    return Results.Created($"/todos/{todo.Id}", todo);
});

app.MapPut("/todos/{id}", async (string id, Todo inputTodo, DaprClient dapr) =>
{
    //var todo = await db.Todos.FindAsync(id);
    var todo = await dapr.GetStateAsync<Todo>(store, id);

    if (todo is null) return Results.NotFound();

    todo.Name = inputTodo.Name;
    todo.IsComplete = inputTodo.IsComplete;

    await dapr.SaveStateAsync<Todo>(store, todo.Id, todo);
    return Results.NoContent();
});

app.Run();

class Todo
{
    public string? Id { get; set; }
    public string? Name { get; set; }
    public bool IsComplete { get; set; }
}

/*class TodoDb : DbContext
{
    public TodoDb(DbContextOptions<TodoDb> options)  : base(options) { }
    public DbSet<Todo> Todos => Set<Todo>();
}*/
