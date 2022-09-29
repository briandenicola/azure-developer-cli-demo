using Dapr.Client;
using System.Text.Json;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);
var client = new DaprClientBuilder().Build();
var store = "dapr-state";

builder.Services.AddSingleton<DaprClient>(client);
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy( policy =>
    {
        policy.WithOrigins("*");
    });
});

var app = builder.Build();
app.UseCors();
app.Urls.Add("http://+:5501");

//For demo purposed only....
var todoItems = new List<String>();

app.MapGet( "/", () =>  $"Hello World! The time now is {DateTime.Now}" );

app.MapGet( "/version", () =>  $"v1" );

app.MapGet("/todos", async (DaprClient dapr) => (await dapr.GetBulkStateAsync(store, todoItems, parallelism: 1)).Select( todo => JsonSerializer.Deserialize<Todo>(todo.Value) ));

app.MapGet("/todos/{id}", async (string id, DaprClient dapr) =>
{
    var todo = await dapr.GetStateAsync<Todo>(store, id);
    
    if( todo is not null) {
       return Results.Ok(todo);
    }
    
    return Results.NotFound();

});

app.MapPost("/todos", async (Todo todo, DaprClient dapr) =>
{
    if (todo is null || todo.Id is null ) return Results.NotFound();

    todoItems.Add(todo.Id);
    await dapr.SaveStateAsync<Todo>(store, todo?.Id, todo);
    return Results.Created($"/todos/{todo?.Id}", todo);
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
    [JsonPropertyName("id")]
    public string? Id { get; set; }
    
    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("isComplete")]
    public bool IsComplete { get; set; }
}