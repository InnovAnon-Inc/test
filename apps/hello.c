#include <linux/module.h>  /* Needed by all modules */
#include <linux/kernel.h>  /* Needed for KERN_ALERT */

MODULE_LICENSE("MIT");
MODULE_AUTHOR("Innovations Anonymous");
MODULE_DESCRIPTION("Android+CMake+GitHub ko test");

int init_module(void)
{
   printk(KERN_ALERT, "Hello world\n");

   // A non 0 return means init_module failed; module can't be loaded.
   return 0;
}

void cleanup_module(void)
{
  printk(KERN_ALERT "Goodbye world 1.\n");
}

