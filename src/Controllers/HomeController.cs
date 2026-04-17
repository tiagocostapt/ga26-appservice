using Microsoft.AspNetCore.Mvc;

namespace GA26Demo.Controllers;

public class HomeController : Controller
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<HomeController> _logger;

    public HomeController(IConfiguration configuration, ILogger<HomeController> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public IActionResult Index()
    {
        var model = new
        {
            ApplicationName = _configuration["APP_NAME"] ?? "GA26 Demo App",
            Environment = _configuration["ASPNETCORE_ENVIRONMENT"],
            DemoValue = _configuration["DEMO_VALUE"] ?? "Click the button to see the API",
            Description = "This demo showcases Azure App Services with Infrastructure as Code"
        };
        
        ViewData["ApplicationName"] = model.ApplicationName;
        ViewData["Environment"] = model.Environment;
        ViewData["DemoValue"] = model.DemoValue;
        ViewData["Description"] = model.Description;
        
        _logger.LogInformation("Home page accessed");
        
        return View();
    }

    public IActionResult Error()
    {
        return View();
    }
}
