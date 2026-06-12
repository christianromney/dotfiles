#!/usr/bin/env bb
;; Tests for memo-keywords. Run: bb ~/bin/memo-keywords-test.clj
(require '[babashka.deps :as deps])
(deps/add-deps '{:deps {org.clojure/test.check {:mvn/version "1.1.1"}}})

(load-file (str (System/getProperty "user.home") "/bin/memo-keywords"))

(ns memo-keywords-test
  (:require [clojure.string :as str]
            [clojure.test :refer [deftest is testing run-tests]]
            [clojure.test.check.clojure-test :refer [defspec]]
            [clojure.test.check.generators :as gen]
            [clojure.test.check.properties :as prop]
            [memo-keywords :as mk]))

;;; Generators

(def gen-slug-word
  (gen/fmap str/join (gen/vector gen/char-alphanumeric 1 8)))

(def gen-slug
  "A valid Denote slug: lowercase alphanumeric words joined by single hyphens."
  (gen/fmap (fn [words] (str/lower-case (str/join "-" words)))
            (gen/vector gen-slug-word 1 4)))

(def gen-keywords (gen/vector gen-slug 0 5))

;;; sluggify-keyword

(deftest sluggify-examples
  (is (= "system-performance" (mk/sluggify-keyword "System Performance")))
  (is (= "bank-charter" (mk/sluggify-keyword "bank_charter")))
  (is (= "occ" (mk/sluggify-keyword "O.C.C.")))
  (is (= "a-b" (mk/sluggify-keyword "--a---b--")))
  (is (= "" (mk/sluggify-keyword nil))))

(defspec sluggify-emits-valid-slugs 200
  (prop/for-all [s gen/string]
    (let [slug (mk/sluggify-keyword s)]
      (or (= "" slug)
          (re-matches #"[a-z0-9]+(?:-[a-z0-9]+)*" slug)))))

(defspec sluggify-is-idempotent 200
  (prop/for-all [s gen/string]
    (let [slug (mk/sluggify-keyword s)]
      (= slug (mk/sluggify-keyword slug)))))

;;; parse-filename / render-filename

(deftest parse-filename-examples
  (is (= {:identifier "20220422T000000" :signature nil
          :title "2022-04-22" :keywords ["journal"]}
         (mk/parse-filename "20220422T000000--2022-04-22__journal.md")))
  (is (= {:identifier "20220421T132915" :signature nil
          :title "durable-hash-index"
          :keywords ["clojure" "data-structures" "software-design" "system-performance"]}
         (mk/parse-filename
          "20220421T132915--durable-hash-index__clojure_data-structures_software-design_system-performance.md")))
  (is (= {:identifier "20220101T120000" :signature nil
          :title "untagged-note" :keywords []}
         (mk/parse-filename "20220101T120000--untagged-note.md")))
  (is (= {:identifier "20220101T120000" :signature "v2"
          :title "signed-note" :keywords ["reference"]}
         (mk/parse-filename "20220101T120000==v2--signed-note__reference.md")))
  (is (nil? (mk/parse-filename "README.md"))))

(deftest render-filename-examples
  (is (= "20220422T000000--2022-04-22__datomic_journal_meeting.md"
         (mk/render-filename {:identifier "20220422T000000"
                              :title "2022-04-22"
                              :keywords ["meeting" "journal" "datomic"]})))
  (is (= "20220101T120000--untagged-note.md"
         (mk/render-filename {:identifier "20220101T120000"
                              :title "untagged-note"
                              :keywords []}))))

(defspec filename-roundtrips 200
  (prop/for-all [title gen-slug
                 keywords gen-keywords]
    (let [note {:identifier "20240115T093000"
                :signature nil
                :title title
                :keywords (vec (sort (distinct keywords)))}]
      (= note (mk/parse-filename (mk/render-filename note))))))

;;; parse-note / replace-tags

(def sample-content
  (str "---\n"
       "title:      \"2022-04-22\"\n"
       "date:       \"2022-04-22T00:00:00-04:00\"\n"
       "tags:       [\"journal\"]\n"
       "identifier: \"20220422T000000\"\n"
       "signature:  \"\"\n"
       "---\n"
       "\n"
       "# Meeting Agenda\n"
       "\n"
       "Discussed Datomic, with tags: [\"decoy\"] in the body.\n"))

(deftest parse-note-examples
  (let [note (mk/parse-note sample-content)]
    (is (= "2022-04-22" (:title note)))
    (is (= ["journal"] (:tags note)))
    (is (str/starts-with? (:body note) "# Meeting Agenda"))))

(deftest replace-tags-preserves-alignment-and-body
  (let [rewritten (mk/replace-tags sample-content ["datomic" "journal" "meeting"])]
    (is (str/includes? rewritten
                       "tags:       [\"datomic\", \"journal\", \"meeting\"]"))
    ;; the decoy tags-like text in the body is untouched
    (is (str/includes? rewritten "tags: [\"decoy\"] in the body"))
    ;; only the front-matter tags line differs
    (is (= (count (str/split-lines sample-content))
           (count (str/split-lines rewritten))))
    (is (= 1 (count (remove (set (str/split-lines sample-content))
                            (str/split-lines rewritten)))))))

(defspec replace-tags-roundtrips 100
  (prop/for-all [tags (gen/fmap #(vec (sort (distinct %)))
                                (gen/vector gen-slug 1 5))]
    (= tags (:tags (mk/parse-note (mk/replace-tags sample-content tags))))))

;;; extract-json

(deftest extract-json-examples
  (testing "raw JSON object"
    (is (= {:keywords ["datomic"] :proposed []}
           (mk/extract-json "{\"keywords\": [\"datomic\"], \"proposed\": []}"))))
  (testing "markdown-fenced JSON (MLX backend ignores the format constraint)"
    (is (= {:keywords ["datomic"] :proposed []}
           (mk/extract-json "```json\n{\"keywords\": [\"datomic\"], \"proposed\": []}\n```"))))
  (testing "JSON surrounded by prose"
    (is (= {:keywords [] :proposed ["m-team"]}
           (mk/extract-json
            "Here you go:\n{\"keywords\": [], \"proposed\": [\"m-team\"]}\nHope that helps!"))))
  (testing "bare JSON array (unconstrained MLX models sometimes reply with just the list)"
    (is (= ["leadership" "process"]
           (mk/extract-json "[\"leadership\", \"process\"]"))))
  (testing "no JSON present"
    (is (nil? (mk/extract-json "I could not classify this entry.")))))

(deftest coerce-suggestion-examples
  (testing "object passes through"
    (is (= {:keywords ["datomic"] :proposed ["m-team"]}
           (mk/coerce-suggestion {:keywords ["datomic"] :proposed ["m-team"]}))))
  (testing "bare array becomes the keyword list"
    (is (= {:keywords ["leadership" "process"] :proposed []}
           (mk/coerce-suggestion ["leadership" "process"]))))
  (testing "non-string array members are dropped"
    (is (= {:keywords ["team"] :proposed []}
           (mk/coerce-suggestion ["team" 42 nil]))))
  (testing "anything else is nil"
    (is (nil? (mk/coerce-suggestion nil)))
    (is (nil? (mk/coerce-suggestion "leadership")))))

;;; merge-keywords

(deftest merge-keywords-examples
  (is (= ["journal"] (mk/merge-keywords [])))
  (is (= ["datomic" "journal" "meeting"]
         (mk/merge-keywords ["meeting" "datomic" "meeting" "journal"]))))

(defspec merge-keywords-sorted-distinct-with-journal 100
  (prop/for-all [keywords gen-keywords]
    (let [merged (mk/merge-keywords keywords)]
      (and (some #{"journal"} merged)
           (= merged (vec (sort merged)))
           (= merged (vec (distinct merged)))))))

;;; sanitize-suggestion

(deftest sanitize-suggestion-examples
  (let [vocabulary #{"datomic" "meeting" "strategy" "clojure" "people" "team"}]
    (testing "in-vocab keywords kept, unknowns moved to proposed, journal dropped"
      (is (= {:keywords ["datomic" "meeting"]
              :proposed ["quarterly-review"]}
             (mk/sanitize-suggestion
              {:keywords ["datomic" "journal" "meeting" "Quarterly Review"]
               :proposed []}
              vocabulary))))
    (testing "proposed terms already in vocabulary promote to keywords"
      (is (= {:keywords ["strategy"]
              :proposed ["m-team"]}
             (mk/sanitize-suggestion
              {:keywords [] :proposed ["strategy" "M Team" "journal"]}
              vocabulary))))
    (testing "keywords capped at 5"
      (is (= 5 (count (:keywords
                       (mk/sanitize-suggestion
                        {:keywords ["datomic" "meeting" "strategy" "clojure"
                                    "people" "team"]
                         :proposed []}
                        vocabulary))))))))

;;; Runner

(let [{:keys [fail error]} (run-tests 'memo-keywords-test)]
  (System/exit (if (zero? (+ fail error)) 0 1)))
