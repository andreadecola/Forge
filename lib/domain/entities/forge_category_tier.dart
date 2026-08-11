/// Rilevanza di una categoria del catalogo per un `WorkoutType`
/// (Milestone 5.1, sezione 14/25): un vincolo **SOFT**, mai HARD — un
/// esercizio con tier `excluded` resta comunque eleggibile (a meno di
/// violare un vincolo HARD separato in `ForgeEligibilityService`), riceve
/// solo il punteggio `workoutTypeMatch` più basso.
///
/// `required` è riservato alla composizione a livello di intera scheda
/// (Milestone 5.2: "questo workout type deve includere almeno un
/// esercizio di categoria X"), un vincolo che un singolo esercizio isolato
/// non può ancora esprimere in questa milestone — qui si comporta come
/// `preferred` (punteggio massimo), la differenza sarà usata solo
/// dal futuro compositore.
enum ForgeCategoryTier { required, preferred, neutral, discouraged, excluded }
