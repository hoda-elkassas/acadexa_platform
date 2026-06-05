// file: lib/core/constants/curriculum_strings.dart

abstract class CurriculumStrings {
  // ─── General ────────────────────────────────────────────────────────
  static const appTitle = 'إدارة الخطط الدراسية';
  static const save = 'حفظ';
  static const cancel = 'إلغاء';
  static const delete = 'حذف';
  static const edit = 'تعديل';
  static const add = 'إضافة';
  static const search = 'بحث...';
  static const confirmDelete = 'تأكيد الحذف';
  static const deleteConfirmMessage = 'هل أنت متأكد من حذف هذا العنصر؟';
  static const noData = 'لا توجد بيانات';
  static const loading = 'جاري التحميل...';
  static const retry = 'إعادة المحاولة';
  static const errorOccurred = 'حدث خطأ';
  static const savedSuccessfully = 'تم الحفظ بنجاح';
  static const deletedSuccessfully = 'تم الحذف بنجاح';

  // ─── Study Plans ────────────────────────────────────────────────────
  static const studyPlans = 'الخطط الدراسية';
  static const addStudyPlan = 'إضافة خطة دراسية';
  static const editStudyPlan = 'تعديل الخطة الدراسية';
  static const planName = 'اسم الخطة';
  static const academicYear = 'السنة الأكاديمية';
  static const department = 'القسم';
  static const program = 'البرنامج';
  static const version = 'الإصدار';
  static const totalCreditHours = 'إجمالي الساعات المعتمدة';
  static const minGpa = 'الحد الأدنى للمعدل التراكمي';
  static const status = 'الحالة';
  static const statusDraft = 'مسودة';
  static const statusActive = 'نشطة';
  static const statusArchived = 'مؤرشفة';
  static const effectiveFrom = 'سارية من';
  static const effectiveTo = 'سارية حتى';
  static const copyPlan = 'نسخ الخطة';
  static const exportPlan = 'تصدير الخطة';
  static const importPlan = 'استيراد خطة';
  static const description = 'الوصف';
  static const planStructure = 'هيكل الخطة';
  static const noPlanSelected = 'لم يتم اختيار خطة';

  // ─── Courses ────────────────────────────────────────────────────────
  static const courses = 'المقررات';
  static const manageCourses = 'إدارة المقررات';
  static const addCourse = 'إضافة مقرر';
  static const editCourse = 'تعديل المقرر';
  static const courseCode = 'رمز المقرر';
  static const courseNameAr = 'اسم المقرر (عربي)';
  static const courseNameEn = 'اسم المقرر (إنجليزي)';
  static const creditHours = 'الساعات المعتمدة';
  static const theoryHours = 'ساعات نظري';
  static const practicalHours = 'ساعات عملي';
  static const labHours = 'ساعات معمل';
  static const fieldHours = 'ساعات ميداني';
  static const level = 'المستوى';
  static const term = 'الفصل';
  static const termFall = 'الأول';
  static const termSpring = 'الثاني';
  static const termSummer = 'الصيفي';
  static const courseType = 'نوع المقرر';
  static const typeMandatory = 'إجباري';
  static const typeElective = 'اختياري';
  static const typeProject = 'مشروع';
  static const typeTraining = 'تدريب';
  static const courseDetails = 'تفاصيل المقرر';

  // ─── Prerequisites ──────────────────────────────────────────────────
  static const prerequisites = 'المتطلبات السابقة';
  static const managePrereqs = 'إدارة المتطلبات';
  static const addPrerequisite = 'إضافة متطلب';
  static const requiredCourse = 'المقرر المطلوب';
  static const minGrade = 'الحد الأدنى للدرجة';

  // ─── Elective Groups ────────────────────────────────────────────────
  static const electiveGroups = 'مجموعات الاختيارية';
  static const addElectiveGroup = 'إضافة مجموعة';
  static const editElectiveGroup = 'تعديل المجموعة';
  static const groupName = 'اسم المجموعة';
  static const groupCode = 'رمز المجموعة';
  static const minHours = 'الحد الأدنى للساعات';
  static const maxHours = 'الحد الأقصى للساعات';
  static const minCourses = 'الحد الأدنى للمقررات';
  static const maxCourses = 'الحد الأقصى للمقررات';
  static const assignedCourses = 'المقررات المسندة';

  // ─── Grading ────────────────────────────────────────────────────────
  static const gradePoints = 'نقاط التقدير';
  static const gradingScale = 'سلم التقدير';
  static const gradeAr = 'التقدير (عربي)';
  static const gradeLetter = 'الرمز';
  static const points = 'النقاط';
  static const minScore = 'الحد الأدنى';
  static const maxScore = 'الحد الأقصى';
  static const specialSymbols = 'الرموز الخاصة';

  // ─── Academic Load ──────────────────────────────────────────────────
  static const academicLoadRules = 'قواعد العبء الأكاديمي';
  static const maxHoursFallSpring = 'الحد الأقصى (أول/ثاني)';
  static const minHoursFallSpring = 'الحد الأدنى (أول/ثاني)';
  static const maxHoursSummer = 'الحد الأقصى (صيفي)';
  static const allowOverload = 'السماح بالزيادة';
  static const overloadMinGpa = 'الحد الأدنى للمعدل (زيادة)';
  static const levelPromotionRules = 'قواعد ترفيع المستوى';

  // ─── Field Training ─────────────────────────────────────────────────
  static const fieldTraining = 'التدريب الميداني';
  static const trainingLevels = 'مستويات التدريب';
  static const hoursPerLevel = 'ساعات لكل مستوى';
  static const supervisorWeights = 'أوزان المشرفين';
  static const externalSupervisor = 'المشرف الخارجي';
  static const internalSupervisor = 'المشرف الداخلي';
  static const remoteSupervisor = 'المشرف عن بُعد';
  static const finalExam = 'الاختبار النهائي';

  // ─── Import/Export ──────────────────────────────────────────────────
  static const importCurriculum = 'استيراد منهج';
  static const exportCurriculum = 'تصدير المنهج';
  static const selectFile = 'اختر ملف';
  static const importInProgress = 'جاري الاستيراد...';
  static const importSuccess = 'تم الاستيراد بنجاح';
  static const exportSuccess = 'تم التصدير بنجاح';

  // ─── Departments ────────────────────────────────────────────────────
  static const departments = 'الأقسام';
  static const addDepartment = 'إضافة قسم';
  static const editDepartment = 'تعديل القسم';
  static const departmentCode = 'رمز القسم';
  static const departmentNameAr = 'اسم القسم (عربي)';
  static const departmentNameEn = 'اسم القسم (إنجليزي)';
}
