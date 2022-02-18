using Microsoft.EntityFrameworkCore;
using ng_task1_web_project.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace ng_task1_web_project.Data
{
    public class MyAppDbContext : DbContext 
    {
        //Default Constructor.
        //MyAppDbContext will have the sqpl tables defined, so it should inherit the properties of microsoft DbContext from EntityFrameWork library.
        //It injects one parameter (options) of type microsoft Generic DbContextOptions while passing to it our DbContext.
        //Also use the constructor from the inherited class.
        public MyAppDbContext(DbContextOptions<MyAppDbContext> options) : base(options)
        {
        }

        //Define a table of Users from the USer model:
        public DbSet<User> Users { get; set; }

    }
}
