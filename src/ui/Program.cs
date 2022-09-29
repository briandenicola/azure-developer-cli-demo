using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Fast.Components.FluentUI;

using TodoList;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");
builder.Services.AddFluentUIComponents();
builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri("https://uatapi.icysea-83f7618a.southcentralus.azurecontainerapps.io") });
//builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri(Environment.GetEnvironmentVariable("TODO_API_URI")) });

await builder.Build().RunAsync();
