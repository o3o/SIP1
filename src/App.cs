using SimpleInjector;
namespace SI {

   public interface IDevice { }
   public class Device: IDevice {
      public Device() {
         System.Console.WriteLine("Device CTOR");
      }
   }

   public interface IModel { }
   public class Model: IModel {
      public Model(IDevice dev) {
         System.Console.WriteLine("Model CTOR");
      }
   }

   public interface IView { }
   public class View: IView {
      public View() {
         System.Console.WriteLine("View CTOR");
      }

   }

   public class Presenter {
      public Presenter(IModel model, IView view) {
      }
   }

   internal sealed class App {
      public static void Main(string[] args) {
         var container = new Container();
         container.Register<Presenter>(Lifestyle.Singleton);
         container.Register<IView, View>(Lifestyle.Singleton);
         container.Register<IModel, Model>(Lifestyle.Singleton);
         container.Register<IDevice, Device>(Lifestyle.Singleton);
         container.Verify();
         container.GetInstance<Presenter>();
      }
   }
}
