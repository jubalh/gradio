using Gtk;
using Gee;


namespace Gradio{

	[GtkTemplate (ui = "/de/haecker-felix/gradio/ui/discover-sidebar.ui")]
	public class DiscoverSidebar : Gtk.Box{

		[GtkChild]
		private SearchEntry SearchEntry;
		[GtkChild]
		private Button SearchButton;
		[GtkChild]
		private ListBox CategoriesBox;
		[GtkChild]
		private ListBox ItemsBox;
		[GtkChild]
		private Stack SidebarStack;

		private DiscoverBox dbox;
		private string actual_view = "catergories";

		public DiscoverSidebar(DiscoverBox box){
			dbox = box;

			CategoriesRow home_row = new CategoriesRow("Startseite", "home");
			CategoriesBox.add(home_row);

			CategoriesRow languages_row = new CategoriesRow("Sprachen", "languages");
			CategoriesBox.add(languages_row);

			connect_signals();
		}

		private void connect_signals(){
			CategoriesBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;

				switch(item.action){
					case "home": show_home(); break;
					case "languages": show_languages(); break;
				}
			});

			ItemsBox.row_activated.connect((t,a) => {
				CategoriesRow item = (CategoriesRow)a;

				switch(actual_view){
					case "languages": show_stations_by_language(item.action); break;
				}
			});
		}

		private void show_stations_by_language(string lang){
			if(!App.data_provider.isWorking){
				dbox.show_overview = false;
				string address = StationDataProvider.radio_stations_by_language + lang;
				App.data_provider.get_radio_stations.begin(address, 100, (obj, res) => {
			    		try {
						var search_results = App.data_provider.get_radio_stations.end(res);
						dbox.list_view_results.set_stations(ref search_results);
						dbox.grid_view_results.set_stations(ref search_results);
			    		} catch (ThreadError e) {
						string msg = e.message;
						stderr.printf("Error: Thread:" + msg+ "\n");
			    		}
        			});
			}
		}

		private void show_languages(){
			actual_view = "languages";
			Util.remove_all_items_from_list_box((Gtk.ListBox) ItemsBox);

			if(StationDataProvider.languages_list != null){
				foreach (string language in StationDataProvider.languages_list){
					CategoriesRow box = new CategoriesRow(language, language);
					ItemsBox.add(box);
				}
			}
			SidebarStack.set_visible_child_name("items");
		}

		private void show_home(){
			dbox.show_overview_page();
		}

		private void show_catergories_page(){
			actual_view = "catergories";
			SidebarStack.set_visible_child_name("catergories");
		}

		[GtkCallback]
		private void BackButton_clicked(){
			show_catergories_page();
		}

		[GtkCallback]
		private void SearchButton_clicked(){
			string address = StationDataProvider.radio_stations_by_name + Util.optimize_string(SearchEntry.get_text());

			if(!App.data_provider.isWorking){
				dbox.show_overview = false;
				App.data_provider.get_radio_stations.begin(address, 100, (obj, res) => {
			    		try {
						var search_results = App.data_provider.get_radio_stations.end(res);
						dbox.list_view_results.set_stations(ref search_results);
						dbox.grid_view_results.set_stations(ref search_results);
			    		} catch (ThreadError e) {
						string msg = e.message;
						stderr.printf("Error: Thread:" + msg+ "\n");
			    		}
        			});
			}

		}


	}
}
