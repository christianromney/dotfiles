#!/usr/bin/env bb

(require '[cheshire.core :as json]
         '[clojure.string :as str])

;; ── Catppuccin Frappe palette ────────────────────────────────────────────────

(def colors
  "Catppuccin Frappe ANSI 24-bit color escape codes, keyed by role.
   :reset and :dim are SGR attributes; all others are foreground colors."
  {:reset    "\033[0m"
   :dim      "\033[2m"
   :green    "\033[38;2;166;209;137m"   ; #a6d189
   :lavender "\033[38;2;186;187;241m"   ; #babbf1
   :mauve    "\033[38;2;202;158;230m"   ; #ca9ee6
   :overlay1 "\033[38;2;131;139;167m"   ; #838ba7
   :red      "\033[38;2;231;130;132m"   ; #e78284
   :peach    "\033[38;2;239;159;118m"}) ; #ef9f76

;; ── Data extraction ──────────────────────────────────────────────────────────

(defn status-data
  "Given `input`, a keyword-keyed map parsed from Claude Code's statusline
   JSON payload, returns a map with keys:
   - :model        string display name; empty string if absent
   - :used         number, context window used percentage (optional)
   - :total-in     number, cumulative input tokens (optional)
   - :total-out    number, cumulative output tokens (optional)
   - :cost-usd     number, total session cost in USD (optional)
   - :session-name string, human-readable session name (optional)
   - :session-id   string, unique session identifier (optional)
   - :agent-name   string, agent name when running with --agent flag (optional)"
  [input]
  {:model        (or (get-in input [:model :display_name]) "")
   :used         (get-in input [:context_window :used_percentage])
   :total-in     (get-in input [:context_window :total_input_tokens])
   :total-out    (get-in input [:context_window :total_output_tokens])
   :cost-usd     (get-in input [:cost :total_cost_usd])
   :session-name (:session_name input)
   :session-id   (:session_id input)
   :agent-name   (get-in input [:agent :name])})

;; ── Segment renderers ────────────────────────────────────────────────────────

(defn user-segment
  "Given `user` (string, system username) and `colors` (map of ANSI escape
   codes), returns an overlay1-colored username string.
   Returns nil if `user` is blank or nil."
  [user colors]
  (when-not (str/blank? user)
    (str (:overlay1 colors) user (:reset colors))))

(defn model-segment
  "Given `model` (string display name) and `colors` (map of ANSI escape
   codes), returns a lavender-colored model name string.
   Returns nil if `model` is blank or nil."
  [model colors]
  (when-not (str/blank? model)
    (str (:lavender colors) model (:reset colors))))

(defn context-segment
  "Given `used` (number, pre-calculated context window used percentage) and
   `colors` (map of ANSI escape codes), returns a colored context-usage
   string. Color scales from green to peach to red as usage increases past
   75% and 90%. Returns nil if `used` is nil."
  [used colors]
  (when used
    (let [pct   (int used)
          color (cond (>= pct 90) (:red colors)
                      (>= pct 75) (:peach colors)
                      :else       (:green colors))]
      (str color "Context: " pct "% Used" (:reset colors)))))

(defn token-segment
  "Given `total-in` and `total-out` (numbers, cumulative token counts) and
   `colors` (map of ANSI escape codes), returns a formatted token-count
   string with counts expressed in thousands (e.g. \"3.2k↑ 1.1k↓\").
   Returns nil if either count is nil."
  [total-in total-out colors]
  (when (and total-in total-out)
    (str (:overlay1 colors) "Tokens: "
         (format "%.1fk" (/ (double total-in)  1000)) "↑ "
         (format "%.1fk" (/ (double total-out) 1000)) "↓"
         (:reset colors))))

(defn cost-segment
  "Given `cost-usd` (number, session cost in USD) and `colors` (map of ANSI
   escape codes), returns a formatted cost string (e.g. \"Cost: $0.0142\").
   Returns nil if `cost-usd` is nil."
  [cost-usd colors]
  (when cost-usd
    (str (:mauve colors) "Cost: " (format "$%.4f" (double cost-usd)) (:reset colors))))


(defn session-segment
  "Given `session-name` and `session-id` (strings or nil) and `colors` (map
   of ANSI escape codes), returns a dimmed bracketed string combining the
   non-blank values joined by \" · \" (e.g. \"[my-session · c3b86c4d054a]\").
   When `session-id` is a UUID, only the last hyphen-separated segment is shown.
   Returns nil if both are blank or nil."
  [session-name session-id colors]
  (let [short-id (when-not (str/blank? session-id) (last (str/split session-id #"-")))
        parts    (remove str/blank? [session-name short-id])]
    (when (seq parts)
      (str (:dim colors) (:overlay1 colors)
           "[" (str/join " · " parts) "]"
           (:reset colors)))))

(defn agent-segment
  "Given `agent-name` (string or nil) and `colors` (map of ANSI escape
   codes), returns a formatted agent-name string. Present only when Claude
   Code is running with the --agent flag. Returns nil if `agent-name` is
   blank or nil."
  [agent-name colors]
  (when-not (str/blank? agent-name)
    (str (:lavender colors) "Agent: " agent-name (:reset colors))))

;; ── Assembly ─────────────────────────────────────────────────────────────────

(defn status-line
  "Given keyword arguments :data (map as returned by `status-data`), :user
   (string, username), and :colors (map of ANSI escape codes), returns the
   assembled statusline string with non-nil segments joined by a dimmed
   separator."
  [& {:keys [data user colors]}]
  (let [sep   (str (:dim colors) (:overlay1 colors) " " (:reset colors))
        parts (remove nil?
                [(user-segment    user colors)
                 (session-segment (:session-name data) (:session-id data) colors)
                 (model-segment   (:model data) colors)
                 (context-segment (:used data) colors)
                 (token-segment   (:total-in data) (:total-out data) colors)
                 (cost-segment    (:cost-usd data) colors)])]
    (str/join sep parts)))

;; ── Entry point ──────────────────────────────────────────────────────────────

(let [input    (json/parse-string (slurp *in*) true)
      username (System/getProperty "user.name")]
  (print (status-line :data (status-data input) :colors colors :user username)))
