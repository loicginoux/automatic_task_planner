# encoding: utf-8
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'date'
require 'fileutils'
require_relative 'event_manager'


email_list = [
 # ADD HERE A LIST OF EMAILS PARTICIPANTS EMAILS
 # ex:
 # "test@gmail.com", "test2@gmail.com"
]

tasks_list = [
  {title: "Limpieza bano",
    freq: 7
  },
  {title: "Barrer & fregar suelos de todos los espacios",
    freq: 14
  },
  {title: "Limpieza cristales: puerta & escaparate",
    freq: 7
  },
  {title: "Limpieza cristales: pecera &  salas de reuniones.",
    freq: 60
  },
  {title: "Limpiar el polvo de estanterías, mesas, muebles etc…",
    freq: 30
  },
  {title: "Sacar basura",
    freq: 7,
    days_length: 6,
  },
  {title: "Recoger 5 euros & compras",
    description: "Recoger 5 euros mensuales de cada persona que coma en CO&ART y comprar cosas que hagan falta: aceite, especias, leche, galletas",
    freq: 30,
    days_length: 29},
  {title: "Llevar a casa los trapos sucios y lavarlos",
    freq: 14
  },
  {title: "Preparar las salas de reuniones",
    description: "Preparar las salas de reuniones para que estén listas cuando alguien de fuera las contrate.",
    freq: 7,
    days_length: 6},
  # {title: "Abrir la puerta, responder al telefono, atender a los visitantes",
  #   freq: 1
  # },
]

em = EventManager.new()


tasks_list.each do |task|
  task_start_date = Date.today + 3
  suffled_email_list = email_list.shuffle #we randomize the order of people
  i = 0
  while task_start_date.year == 2015
    email = suffled_email_list[i%suffled_email_list.length]
    # if not specify task is one day
    length_task = (task[:days_length].nil?) ? 1 : task[:days_length]
    task_end_date = task_start_date + length_task

    event = em.create_event(task[:title], task[:description], email, task_start_date, task_end_date, )
    em.add_event(event)

    # increment start date for next time this task need to be done
    task_start_date += task[:freq]

    if task_start_date.wday == 0 #sunday
      task_start_date += 1
    elsif task_start_date.wday == 6 #saturday
      task_start_date += 2
    end
    i += 1
  end
end

em.fetch_next_events(10)
