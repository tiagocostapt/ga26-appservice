using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;

var builder = WebApplication.CreateBuilder(args);

// Add Application Insights
builder.Services.AddApplicationInsightsTelemetry();

// Add services to the container
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

// API endpoint that showcases environment variables
app.MapGet("/api/config", (IConfiguration config, TelemetryClient telemetryClient) =>
{
    // Log to Application Insights
    telemetryClient.TrackTrace("Config requested", SeverityLevel.Information);
    
    var demo = new
    {
        applicationName = config["APP_NAME"] ?? "GA26 Demo App",
        environment = config["ASPNETCORE_ENVIRONMENT"],
        demoValue = config["DEMO_VALUE"] ?? "Default Demo Value",
        appServiceName = Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME") ?? "Local",
        timestamp = DateTime.UtcNow,
        version = "1.0.0"
    };
    
    return Results.Ok(demo);
});

app.Run();
