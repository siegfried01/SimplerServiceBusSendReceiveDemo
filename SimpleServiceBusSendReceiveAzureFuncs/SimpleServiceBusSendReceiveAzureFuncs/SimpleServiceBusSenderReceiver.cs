using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.WebJobs.ServiceBus;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace SimpleServiceBusSendReceiveAzureFuncs;
public class SimpleServiceBusSenderReceiver
{
    /// <summary>
    /// This function will be triggered when a message is sent to the Service Bus queue.
    /// Using the portal, set the Service Bus connection string in the app settings under Connection Strings using type Custom.
    /// </summary>
    /// <param name="myQueueItem"></param>
    /// <param name="log"></param>
    [FunctionName("SimpleServiceBusReceiver")]
    public void Run([ServiceBusTrigger("mainqueue001", Connection = "ServiceBusConnection")] string myQueueItem, ILogger log)
    {
        log.LogInformation($"C# ServiceBus queue trigger function processed message: {myQueueItem}");
    }
   // https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-output?tabs=python-v2%2Cin-process%2Cnodejs-v4%2Cextensionv5&pivots=programming-language-csharp
    // This function will be triggered by HTTP request and will send a message to the Service Bus queue.
    // https://stackoverflow.com/questions/60607880/how-to-send-data-to-service-bus-topic-with-azure-functions
    [FunctionName("SimpleServiceBusSender")]
    [return: ServiceBus("mainqueue001", Connection = "ServiceBusConnection")]
    public static async Task RunAsync(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
        [ServiceBus("mainqueue001", Connection = "ServiceBusConnection")] MessageSender messagesQueue,
        ILogger log)
    {
        log.LogInformation("C# HTTP trigger function processed a request.");
            string name = req.Query["name"];
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
        dynamic data = JsonConvert.DeserializeObject(requestBody);
        name = name ?? data?.name;
            string responseMessage = string.IsNullOrEmpty(name)
            ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
            : $"Hello, {name}. This HTTP triggered function executed successfully.";
            byte[] bytes = Encoding.ASCII.GetBytes(responseMessage);
            Message m1 = new Message(bytes);
        await messagesQueue.SendAsync(m1);
    }

    //https://learn.microsoft.com/en-us/previous-versions/sandbox/functions-recipes/service-bus#azure-service-bus-output-binding
    [FunctionName("ServiceBusTimerOutput")]
    public static void Run([TimerTrigger("0/10 * * * * *")]TimerInfo myTimer,
                           TraceWriter log,
                           [ServiceBus("mainqueue001", Connection = "ServiceBusConnection", EntityType = EntityType.Queue)]out string queueMessage)
    {
        var now = DateTime.Now.ToString("ddd yyyy-MM-dd HH:mm:ss (ttt)");
        log.Info("101 Azure Function Demo - Azure Service Bus Queue output {now}",now);
        queueMessage = DateTime.UtcNow.ToString();
    }    
}

