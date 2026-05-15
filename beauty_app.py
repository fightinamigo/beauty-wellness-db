
import tkinter as tk
from tkinter import ttk, messagebox
import pyodbc


#  DATABASE CONNECTION  –  edit SERVER_NAME to match your local SQL instance

SERVER_NAME   = r"DESKTOP-MPEO159\SQLEXPRESS"   # e.g. ".\SQLEXPRESS" or "localhost"
DATABASE_NAME = "BeautyWellnessDB"

def get_connection():
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={SERVER_NAME};"
        f"DATABASE={DATABASE_NAME};"
        "Trusted_Connection=yes;"
    )
    return pyodbc.connect(conn_str)



#  HELPER – run a query and return rows + column names

def run_query(sql, params=(), fetch=True):
    conn   = get_connection()
    cursor = conn.cursor()
    cursor.execute(sql, params)
    if fetch:
        cols = [d[0] for d in cursor.description]
        rows = cursor.fetchall()
        conn.close()
        return cols, rows
    else:
        conn.commit()
        conn.close()
        return [], []

#  HELPER – populate a Treeview with query results

def populate_tree(tree, cols, rows):
    tree.delete(*tree.get_children())
    tree["columns"] = cols
    tree["show"]    = "headings"
    for c in cols:
        tree.heading(c, text=c)
        tree.column(c, width=max(100, len(c) * 10), anchor="w")
    for row in rows:
        tree.insert("", "end", values=[str(v) if v is not None else "" for v in row])

#  MAIN APPLICATION WINDOW
class BeautyApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("🌸  Beauty & Wellness Network  –  DB Manager")
        self.geometry("1100x700")
        self.configure(bg="#fdf6f0")
        self._build_ui()

    def _build_ui(self):
        title = tk.Label(
            self, text="Professional Beauty & Wellness Network",
            font=("Helvetica", 16, "bold"), bg="#c27ba0", fg="white",
            pady=10
        )
        title.pack(fill="x")

        # Notebook (tabs)
        style = ttk.Style(self)
        style.theme_use("clam")
        style.configure("TNotebook.Tab", font=("Helvetica", 10, "bold"),
                        padding=[10, 5])

        nb = ttk.Notebook(self)
        nb.pack(fill="both", expand=True, padx=10, pady=10)

        self._add_insert_tab(nb)
        self._add_delete_tab(nb)
        self._add_update_tab(nb)
        self._add_select_tab(nb)
        self._add_join_tab(nb)
        self._add_inquiry_tab(nb)

    def _make_results_frame(self, parent):
        frame = ttk.LabelFrame(parent, text="Results", padding=5)
        frame.pack(fill="both", expand=True, padx=10, pady=5)

        tree = ttk.Treeview(frame, show="headings")
        vsb  = ttk.Scrollbar(frame, orient="vertical",   command=tree.yview)
        hsb  = ttk.Scrollbar(frame, orient="horizontal", command=tree.xview)
        tree.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        vsb.pack(side="right",  fill="y")
        hsb.pack(side="bottom", fill="x")
        tree.pack(fill="both", expand=True)
        return tree

    #  TAB 1 – INSERT

    def _add_insert_tab(self, nb):
        tab = ttk.Frame(nb, padding=10)
        nb.add(tab, text="➕  Insert")

        f1 = ttk.LabelFrame(tab, text="Insert 1 – Add New Client", padding=10)
        f1.pack(fill="x", pady=5)

        fields1 = [("Client ID",       "client_id_var"),
                   ("First Name",       "c_fname_var"),
                   ("Last Name",        "c_lname_var"),
                   ("Email",            "c_email_var"),
                   ("Phone",            "c_phone_var"),
                   ("Membership Type",  "c_mtype_var")]

        for i, (label, var) in enumerate(fields1):
            setattr(self, var, tk.StringVar())
            tk.Label(f1, text=label + ":").grid(row=i//3, column=(i%3)*2,
                                                sticky="e", padx=4, pady=3)
            ttk.Entry(f1, textvariable=getattr(self, var), width=18).grid(
                row=i//3, column=(i%3)*2+1, padx=4, pady=3)

        ttk.Button(f1, text="Add Client",
                   command=self._insert_client).grid(row=3, column=0, columnspan=6, pady=5)

        f2 = ttk.LabelFrame(tab, text="Insert 2 – Schedule New Session", padding=10)
        f2.pack(fill="x", pady=5)

        fields2 = [("Session ID",    "s_id_var"),
                   ("Service ID",    "s_svc_var"),
                   ("Client ID",     "s_clt_var"),
                   ("Therapist ID",  "s_thr_var"),
                   ("Spa ID",        "s_spa_var"),
                   ("DateTime",      "s_dt_var"),
                   ("Room No.",      "s_room_var")]

        for i, (label, var) in enumerate(fields2):
            setattr(self, var, tk.StringVar())
            if var == "s_dt_var":
                getattr(self, var).set("2026-05-10 10:00")
            tk.Label(f2, text=label + ":").grid(row=i//4, column=(i%4)*2,
                                                sticky="e", padx=4, pady=3)
            ttk.Entry(f2, textvariable=getattr(self, var), width=18).grid(
                row=i//4, column=(i%4)*2+1, padx=4, pady=3)

        ttk.Button(f2, text="Schedule Session",
                   command=self._insert_session).grid(row=3, column=0,
                                                      columnspan=8, pady=5)

    def _insert_client(self):
        try:
            sql = """
                INSERT INTO CLIENT (client_id, membership_date, membership_type,
                                    client_fname, client_lname, client_email, client_phone)
                VALUES (?, GETDATE(), ?, ?, ?, ?, ?)
            """
            run_query(sql, (
                self.client_id_var.get(), self.c_mtype_var.get(),
                self.c_fname_var.get(),   self.c_lname_var.get(),
                self.c_email_var.get(),   self.c_phone_var.get()
            ), fetch=False)
            messagebox.showinfo("Success", "✅ Client added successfully!")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def _insert_session(self):
        try:
            sql = """
                INSERT INTO SESSION (session_id, service_id, client_id, therapist_id,
                                     spa_id, scheduled_at, status, room_number)
                VALUES (?, ?, ?, ?, ?, ?, 'Scheduled', ?)
            """
            run_query(sql, (
                self.s_id_var.get(),   self.s_svc_var.get(),
                self.s_clt_var.get(),  self.s_thr_var.get(),
                self.s_spa_var.get(),  self.s_dt_var.get(),
                self.s_room_var.get()
            ), fetch=False)
            messagebox.showinfo("Success", "✅ Session scheduled successfully!")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    #  TAB 2 – DELETE

    def _add_delete_tab(self, nb):
        tab = ttk.Frame(nb, padding=10)
        nb.add(tab, text="🗑️  Delete")

        f1 = ttk.LabelFrame(tab,
             text="Delete 1 – Remove a Session (by ID, only if Scheduled)", padding=10)
        f1.pack(fill="x", pady=10)

        self.del_sess_id = tk.StringVar()
        tk.Label(f1, text="Session ID:").grid(row=0, column=0, padx=5)
        ttk.Entry(f1, textvariable=self.del_sess_id, width=12).grid(row=0, column=1, padx=5)
        ttk.Button(f1, text="Delete Session",
                   command=self._delete_session).grid(row=0, column=2, padx=10)

        f2 = ttk.LabelFrame(tab,
             text="Delete 2 – Remove Client (only if they have NO sessions)", padding=10)
        f2.pack(fill="x", pady=10)

        self.del_client_id = tk.StringVar()
        tk.Label(f2, text="Client ID:").grid(row=0, column=0, padx=5)
        ttk.Entry(f2, textvariable=self.del_client_id, width=12).grid(row=0, column=1, padx=5)
        ttk.Button(f2, text="Delete Client",
                   command=self._delete_client).grid(row=0, column=2, padx=10)

    def _delete_session(self):
        try:
            sql = "DELETE FROM SESSION WHERE session_id = ? AND status = 'Scheduled'"
            run_query(sql, (self.del_sess_id.get(),), fetch=False)
            messagebox.showinfo("Success", "✅ Session deleted (if it existed and was Scheduled).")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def _delete_client(self):
        try:
            sql = """
                DELETE FROM CLIENT
                WHERE client_id = ?
                  AND client_id NOT IN (SELECT DISTINCT client_id FROM SESSION)
            """
            run_query(sql, (self.del_client_id.get(),), fetch=False)
            messagebox.showinfo("Success", "✅ Client deleted (if they had no sessions).")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    #  TAB 3 – UPDATE

    def _add_update_tab(self, nb):
        tab = ttk.Frame(nb, padding=10)
        nb.add(tab, text="✏️  Update")

        f1 = ttk.LabelFrame(tab,
             text="Update 1 – Mark Session as Completed (only if currently Scheduled)",
             padding=10)
        f1.pack(fill="x", pady=10)

        self.upd_sess_id = tk.StringVar()
        tk.Label(f1, text="Session ID:").grid(row=0, column=0, padx=5)
        ttk.Entry(f1, textvariable=self.upd_sess_id, width=12).grid(row=0, column=1, padx=5)
        ttk.Button(f1, text="Mark Completed",
                   command=self._update_session_status).grid(row=0, column=2, padx=10)

        f2 = ttk.LabelFrame(tab,
             text="Update 2 – Restock Product (add quantity by product category)",
             padding=10)
        f2.pack(fill="x", pady=10)

        self.upd_prod_id  = tk.StringVar()
        self.upd_qty      = tk.StringVar()
        self.upd_cat      = tk.StringVar()
        tk.Label(f2, text="Product ID:").grid(row=0, column=0, padx=5)
        ttk.Entry(f2, textvariable=self.upd_prod_id, width=12).grid(row=0, column=1, padx=5)
        tk.Label(f2, text="Add Qty:").grid(row=0, column=2, padx=5)
        ttk.Entry(f2, textvariable=self.upd_qty, width=8).grid(row=0, column=3, padx=5)
        tk.Label(f2, text="Category:").grid(row=0, column=4, padx=5)
        ttk.Entry(f2, textvariable=self.upd_cat, width=15).grid(row=0, column=5, padx=5)
        ttk.Button(f2, text="Restock",
                   command=self._update_stock).grid(row=0, column=6, padx=10)

    def _update_session_status(self):
        try:
            sql = """
                UPDATE SESSION SET status = 'Completed'
                WHERE session_id = ? AND status = 'Scheduled'
            """
            run_query(sql, (self.upd_sess_id.get(),), fetch=False)
            messagebox.showinfo("Success", "✅ Session marked as Completed.")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    def _update_stock(self):
        try:
            sql = """
                UPDATE PRODUCT
                SET stock_quantity = stock_quantity + ?
                WHERE product_id = ? AND product_category = ?
            """
            run_query(sql, (
                int(self.upd_qty.get()),
                int(self.upd_prod_id.get()),
                self.upd_cat.get()
            ), fetch=False)
            messagebox.showinfo("Success", "✅ Product stock updated.")
        except Exception as e:
            messagebox.showerror("Error", str(e))

    #  TAB 4 – SELECT (single-table)

    def _add_select_tab(self, nb):
        tab = ttk.Frame(nb, padding=10)
        nb.add(tab, text="🔍  Select")

        btn_frame = ttk.Frame(tab)
        btn_frame.pack(fill="x", pady=5)

        queries = [
            ("All Spa Locations",    "SELECT spa_id, name, city, num_private_rooms, address, spa_phone FROM SPA_LOCATION"),
            ("All Clients",          "SELECT client_id, client_fname+' '+client_lname AS full_name, client_email, client_phone, membership_type, membership_date FROM CLIENT"),
            ("Services by Price",    "SELECT service_id, service_name, service_category, duration_minutes, price, therapeutic_benefit FROM SERVICE ORDER BY price DESC"),
            ("Completed Sessions",   "SELECT session_id, scheduled_at, room_number, status, client_id, therapist_id FROM SESSION WHERE status='Completed'"),
            ("Product Inventory",    "SELECT product_id, product_name, brand, product_category, stock_quantity, unit FROM PRODUCT ORDER BY stock_quantity"),
            ("All Therapists",       "SELECT therapist_id, therapist_fname+' '+therapist_lname AS name, therapist_email, therapist_phone, spa_id, hire_date FROM THERAPIST"),
        ]

        self.select_tree = self._make_results_frame(tab)

        for label, sql in queries:
            ttk.Button(
                btn_frame, text=label,
                command=lambda s=sql: self._run_and_show(s, self.select_tree)
            ).pack(side="left", padx=4, pady=4)

    def _run_and_show(self, sql, tree, params=()):
        try:
            cols, rows = run_query(sql, params)
            populate_tree(tree, cols, rows)
        except Exception as e:
            messagebox.showerror("DB Error", str(e))

    #  TAB 5 – SELECT with JOINs

    def _add_join_tab(self, nb):
        tab = ttk.Frame(nb, padding=10)
        nb.add(tab, text="🔗  Joins")

        btn_frame = ttk.Frame(tab)
        btn_frame.pack(fill="x", pady=5)

        join_queries = [
            ("Session Full Details", """
                SELECT s.session_id,
                       c.client_fname+' '+c.client_lname  AS client_name,
                       t.therapist_fname+' '+t.therapist_lname AS therapist_name,
                       sv.service_name, sv.price, sp.name AS spa_name,
                       s.scheduled_at, s.status, s.room_number
                FROM SESSION s
                JOIN CLIENT c       ON s.client_id    = c.client_id
                JOIN THERAPIST t    ON s.therapist_id = t.therapist_id
                JOIN SERVICE sv     ON s.service_id   = sv.service_id
                JOIN SPA_LOCATION sp ON s.spa_id      = sp.spa_id
            """),
            ("Product Usage per Session", """
                SELECT sp.sp_id, ses.session_id, ses.scheduled_at,
                       p.product_name, p.brand, sp.quantity_used, p.unit
                FROM SESSION_PRODUCT sp
                JOIN SESSION ses ON sp.session_id = ses.session_id
                JOIN PRODUCT  p  ON sp.product_id = p.product_id
            """),
            ("Therapist Skills & Certification", """
                SELECT t.therapist_fname+' '+t.therapist_lname AS therapist_name,
                       spa.name AS spa_name,
                       sk.skill_name,
                       cd.certified_date
                FROM THERAPIST_SKILL ts
                JOIN THERAPIST     t   ON ts.therapist_id = t.therapist_id
                JOIN SKILL         sk  ON ts.skill_id     = sk.skill_id
                JOIN SPA_LOCATION  spa ON t.spa_id        = spa.spa_id
                LEFT JOIN CERTIFIED_DATE cd
                    ON cd.therapist_id = ts.therapist_id AND cd.skill_id = ts.skill_id
            """),
            ("Clients & Their Sessions", """
                SELECT c.client_fname+' '+c.client_lname AS client_name,
                       c.membership_type, c.client_email,
                       COUNT(s.session_id) AS total_sessions,
                       SUM(sv.price)       AS total_spent
                FROM CLIENT c
                LEFT JOIN SESSION s  ON s.client_id  = c.client_id
                LEFT JOIN SERVICE sv ON sv.service_id = s.service_id
                GROUP BY c.client_id, c.client_fname, c.client_lname,
                         c.membership_type, c.client_email
                ORDER BY total_spent DESC
            """),
        ]

        self.join_tree = self._make_results_frame(tab)

        for label, sql in join_queries:
            ttk.Button(
                btn_frame, text=label,
                command=lambda s=sql: self._run_and_show(s, self.join_tree)
            ).pack(side="left", padx=4, pady=4)

    #  TAB 6 – INQUIRY QUERIES (all 6 from project spec)

    def _add_inquiry_tab(self, nb):
        tab = ttk.Frame(nb, padding=10)
        nb.add(tab, text="📊  Inquiries")

        btn_frame = ttk.Frame(tab)
        btn_frame.pack(fill="x", pady=5)

        inquiries = [
            ("1. Most Popular Service", """
                SELECT TOP 1 sv.service_name, sv.service_category,
                       COUNT(s.session_id) AS total_bookings
                FROM SESSION s
                JOIN SERVICE sv ON s.service_id = sv.service_id
                GROUP BY sv.service_name, sv.service_category
                ORDER BY total_bookings DESC
            """),
            ("2. Therapists with No Sessions Last Month", """
                SELECT t.therapist_id,
                       t.therapist_fname+' '+t.therapist_lname AS therapist_name,
                       t.therapist_email, sp.name AS spa_name
                FROM THERAPIST t
                JOIN SPA_LOCATION sp ON t.spa_id = sp.spa_id
                WHERE t.therapist_id NOT IN (
                    SELECT DISTINCT therapist_id FROM SESSION
                    WHERE MONTH(scheduled_at) = MONTH(DATEADD(MONTH,-1,GETDATE()))
                      AND YEAR(scheduled_at)  = YEAR(DATEADD(MONTH,-1,GETDATE()))
                )
            """),
            ("3. Top Spender on Premium Services", """
                SELECT TOP 1
                       c.client_fname+' '+c.client_lname AS client_name,
                       c.membership_type,
                       SUM(sv.price) AS total_spent
                FROM SESSION s
                JOIN CLIENT  c  ON s.client_id  = c.client_id
                JOIN SERVICE sv ON s.service_id = sv.service_id
                WHERE sv.service_category = 'Massage'
                  AND MONTH(s.scheduled_at) = MONTH(DATEADD(MONTH,-1,GETDATE()))
                  AND YEAR(s.scheduled_at)  = YEAR(DATEADD(MONTH,-1,GETDATE()))
                GROUP BY c.client_id, c.client_fname, c.client_lname, c.membership_type
                ORDER BY total_spent DESC
            """),
            ("4. Services NOT Booked Last Month", """
                SELECT sv.service_id, sv.service_name,
                       sv.service_category, sv.price, sv.duration_minutes
                FROM SERVICE sv
                WHERE sv.service_id NOT IN (
                    SELECT DISTINCT service_id FROM SESSION
                    WHERE MONTH(scheduled_at) = MONTH(DATEADD(MONTH,-1,GETDATE()))
                      AND YEAR(scheduled_at)  = YEAR(DATEADD(MONTH,-1,GETDATE()))
                )
            """),
            ("5. Therapists Available per Spa", """
                SELECT sp.name AS spa_name, sp.city,
                       t.therapist_fname+' '+t.therapist_lname AS therapist_name,
                       sk.skill_name
                FROM SPA_LOCATION sp
                JOIN THERAPIST      t  ON t.spa_id       = sp.spa_id
                JOIN THERAPIST_SKILL ts ON ts.therapist_id = t.therapist_id
                JOIN SKILL          sk ON sk.skill_id    = ts.skill_id
                ORDER BY sp.name, t.therapist_lname
            """),
            ("6. Therapist Profiles & Sessions Completed", """
                SELECT t.therapist_id,
                       t.therapist_fname+' '+t.therapist_lname AS therapist_name,
                       t.therapist_email, t.therapist_phone,
                       sp.name AS primary_spa,
                       COUNT(s.session_id) AS total_completed_sessions
                FROM THERAPIST t
                JOIN SPA_LOCATION sp ON t.spa_id = sp.spa_id
                LEFT JOIN SESSION s  ON s.therapist_id = t.therapist_id
                                     AND s.status = 'Completed'
                GROUP BY t.therapist_id, t.therapist_fname, t.therapist_lname,
                         t.therapist_email, t.therapist_phone, sp.name
                ORDER BY total_completed_sessions DESC
            """),
        ]

        self.inq_tree = self._make_results_frame(tab)

        row1 = ttk.Frame(btn_frame)
        row2 = ttk.Frame(btn_frame)
        row1.pack(fill="x")
        row2.pack(fill="x")

        for i, (label, sql) in enumerate(inquiries):
            parent = row1 if i < 3 else row2
            ttk.Button(
                parent, text=label,
                command=lambda s=sql: self._run_and_show(s, self.inq_tree)
            ).pack(side="left", padx=4, pady=4)

if __name__ == "__main__":
    app = BeautyApp()
    app.mainloop()
