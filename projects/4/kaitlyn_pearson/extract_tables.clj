(defn extract-tables [html tags]
  (let [[table-tag row-tag cell-tag] tags]
    (for [[_ table] (re-seq (re-pattern (str "(?s)<" table-tag ".*?>(.*?)</" table-tag ">")) html)]
      (let [rows (re-seq (re-pattern (str "(?s)<" row-tag ".*?>(.*?)</" row-tag ">")) table)]
        (for [[_ row] rows]
          (let [cells (re-seq (re-pattern (str "(?s)<" cell-tag ".*?>(.*?)</" cell-tag ">")) row)]
            (mapv (fn [[_ cell]]
                    (-> cell
                        (clojure.string/replace #"<.*?>" "")
                        (clojure.string/trim)))
                  cells)))))))

(defn get-output-filename [input-path index]
  (let [file-name (.getName (clojure.java.io/file input-path))
        base-name (clojure.string/replace file-name #"\.[^.]+$" "")]
    (str base-name "_table_" (inc index) ".csv")))

(defn save-tables-to-csv [tables input-filename]
  (doseq [[index table] (map-indexed vector tables)]
    (let [filename (get-output-filename input-filename index)
          csv-content (clojure.string/join "\n" (map #(clojure.string/join "," %) table))] ;; Convert table to CSV format
      (spit filename csv-content))))

(defn process-file [filepath]
  (let [html (slurp filepath)
        tables (extract-tables html ["table" "tr" "t[dh]"])]
    (save-tables-to-csv tables filepath)
    (count tables)))

(defn time-it [label f]
  (let [start (System/nanoTime)]
    (let [result (f)]
      (println label "Execution Time:" (/ (- (System/nanoTime) start) 1e9) "seconds")
      result)))

(defn run-sequential [files]
  (doseq [file files]
    (process-file file)))

(defn run-parallel [files]
  (doall (map deref (map #(future (process-file %)) files))))

;; === Run the Program ===

(def files ["page1.html" "page2.html" "page3.html"])

(time-it "Sequential" #(run-sequential files))
(time-it "Multithreaded" #(run-parallel files))
