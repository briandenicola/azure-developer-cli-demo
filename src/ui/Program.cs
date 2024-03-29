using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.Fast.Components.FluentUI;

using TodoList;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");
builder.Services.AddFluentUIComponents();
builder.Services.AddScoped(sp => new HttpClient { BaseAddress = new Uri( builder.Configuration["API_URI"] ?? builder.HostEnvironment.BaseAddress) });

await builder.Build().RunAsync();
