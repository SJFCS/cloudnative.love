// eslint-disable-next-line @typescript-eslint/no-unused-vars
import React from 'react';
import { Navigation, Scrollbar, A11y, EffectCoverflow, Autoplay } from 'swiper/modules';
import { Swiper, SwiperSlide } from 'swiper/react';
import 'swiper/css';
import 'swiper/css/navigation';
import 'swiper/css/scrollbar';
import 'swiper/css/effect-coverflow';
import './Swiper.css';
import Translate, { translate } from '@docusaurus/Translate';

const data = [
  { cover: require('@site/static/img/cert/CKA.webp').default, title: <Translate>Certified Kubernetes Administrator (CKA)</Translate> },
  { cover: require('@site/static/img/cert/CKS.webp').default, title: <Translate>Certified Kubernetes Security Specialist (CKS)</Translate> },
  { cover: require('@site/static/img/cert/RHCE.webp').default, title: <Translate>Red Hat Certified Engineer (RHCE)</Translate> },
  { cover: require('@site/static/img/cert/ACP.webp').default, title: <Translate>Alibaba Cloud Certified Professional - Cloud Computing (ACP)</Translate> },
  { cover: require('@site/static/img/cert/RHCSA.webp').default, title: <Translate>Red Hat Certified System Administrator (RHCSA)</Translate> },
  { cover: require('@site/static/img/cert/ACA-DEVOPS.webp').default, title: <Translate>Alibaba Cloud Certified Associate - DevOps (ACA)</Translate> },
  { cover: require('@site/static/img/cert/H3CNE-Cloud.webp').default, title: <Translate>H3C Certified Network Engineer for Cloud (H3CNE-Cloud)</Translate> },
  { cover: require('@site/static/img/cert/H3CNE-Net.webp').default, title: <Translate>H3C Certified Network Engineer (H3CNE)</Translate> },
  { cover: require('@site/static/img/cert/2018年山东省职业院校技能大赛 云计算技术与应用赛项 二等奖.webp').default, title: <Translate>2018 Shandong Province Vocational College Cloud Computing Technology and Applications Competition Second Prize</Translate> },
  { cover: require('@site/static/img/cert/2018年山东省职业院校 云计算大数据行业技能大赛 一等奖.webp').default, title: <Translate>2018 Shandong vocational colleges cloud computing big data industry skills competition first prize</Translate> },
  { cover: require('@site/static/img/cert/云计算大数据讲师认证证书.webp').default, title: <Translate>Cloud computing big data lecturer certification (CETC)</Translate> },
  { cover: require('@site/static/img/cert/ArgoCD-AKUITY.webp').default, title: <Translate>Introduction to Continuous Delivery and GitOps using Argo CD</Translate> },
  { cover: require('@site/static/img/cert/HCNA-AI.webp').default, title: <Translate>Huawei Certified Artificial Intelligence(HCNA-AI)</Translate> },
  // { cover: require('@site/static/img/cert/大学生网络安全知识竞赛证书.webp').default, title: <Translate>Certificate of University Student Network Security Knowledge Contest</Translate> },
  { cover: require('@site/static/img/cert/CKAD.webp').default, title: <Translate>Certified Kubernetes Application Developer (CKAD)</Translate> },
];

const SwiperCarousel = () => {
  const slides = data.map((item, index) => (
    <SwiperSlide key={index}>
      <div className="Swiper-flex">
        <img className="swiperImgShadow" loading="lazy" src={item.cover} alt={item.title} />
        <div className="underImg">{item.title}</div>
      </div>
    </SwiperSlide>
  ));

  return (
    <Swiper
      modules={[Navigation, Scrollbar, A11y, EffectCoverflow, Autoplay]}
      spaceBetween={-200}
      slidesPerView={3}
      navigation
      loop
      simulateTouch
      centeredSlides
      autoplay={{ delay: 3000, disableOnInteraction: false }}
      effect="coverflow"
      coverflowEffect={{
        rotate: 0,
        stretch: 0,
        depth: 250,
        modifier: 1,
        slideShadows: false,
      }}
      breakpoints={{
        700: {
          spaceBetween: -100,
          slidesPerView: 3,
        },
        500: {
          spaceBetween: -100,
          slidesPerView: 2,
        },
        300: {
          spaceBetween: -100,
          slidesPerView: 1,
        },
      }}
    >
      {slides}
    </Swiper>
  );
};

export default SwiperCarousel;
