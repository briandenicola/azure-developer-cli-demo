using Dapr.Client;
using Microsoft.Extensions.Logging;

var builder = WebApplication.CreateBuilder(args);
var client = new DaprClientBuilder().Build();
var store = "dapr-state";

builder.Services.AddSingleton<DaprClient>(client);

var app = builder.Build();
app.Urls.Add("http://+:5501");

app.MapGet( "/", () =>  $"Hello World! The time now is {DateTime.Now}" );

//app.MapGet("/todos", async (TodoDb db) => await db.Todos.ToListAsync());

app.MapGet("/todos/{id}", async (string id,DaprClient dapr) =>
{
    var todo = await dapr.GetStateAsync<Todo>(store, id);
    
    if( todo is not null) {
       return Results.Ok(todo);
    }
    
    return Results.NotFound();

});

app.MapPost("/todos", async (Todo todo, DaprClient dapr) =>
{
    await dapr.SaveStateAsync<Todo>(store, todo.Id, todo);
    return Results.Created($"/todos/{todo.Id}", todo);
});

app.MapPut("/todos/{id}", async (string id, Todo inputTodo, DaprClient dapr) =>
{
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